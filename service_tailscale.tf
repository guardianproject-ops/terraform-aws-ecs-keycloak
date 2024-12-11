# This is ECS service that runs tailscale as an HTTP ingress
# that is only accessible for the tailnet
module "label_tailscale" {
  source     = "cloudposse/label/null"
  version    = "0.25.0"
  context    = module.this.context
  attributes = ["tailscale", "ingress"]
}

resource "aws_efs_file_system" "tailscale_state" {
  count          = module.this.enabled ? 1 : 0
  creation_token = module.label_tailscale.id
  encrypted      = true
  kms_key_id     = local.kms_key_arn
  tags           = module.this.tags
}

resource "aws_efs_access_point" "tailscale_state" {
  count          = module.this.enabled ? 1 : 0
  file_system_id = aws_efs_file_system.tailscale_state[0].id
  root_directory {
    path = "/${module.label_tailscale.id}"
    creation_info {
      owner_uid   = 0
      owner_gid   = 0
      permissions = "770"
    }
  }
  posix_user {
    uid = 0
    gid = 0
  }
  tags = module.this.tags
}

resource "aws_efs_mount_target" "tailscale_state" {
  count           = module.this.enabled ? length(var.private_subnet_ids) : 0
  file_system_id  = aws_efs_file_system.tailscale_state[0].id
  subnet_id       = var.private_subnet_ids[count.index]
  security_groups = [aws_security_group.ecs_to_efs[0].id]
}

module "tailscale_def" {
  source          = "cloudposse/ecs-container-definition/aws"
  version         = "0.61.1"
  container_name  = "tailscale"
  container_image = var.tailscale_container_image
  essential       = true

  container_depends_on = [
    {
      condition     = "SUCCESS"
      containerName = "tailscale-init"
    }
  ]
  mount_points = [
    {
      containerPath = "/var/lib/tailscale"
      readOnly      = false
      sourceVolume  = "tailscale-state"
    },
    {
      containerPath = "/config"
      readOnly      = true
      sourceVolume  = "tailscale-config"
    }
  ]

  secrets = [
    {
      name      = "TS_AUTHKEY",
      valueFrom = "${aws_secretsmanager_secret.authkey[0].arn}:auth_key::"
    },
  ]
  environment = [
    {
      name = "TS_EXTRA_ARGS"
      value = join(" ", [
        "--ssh"
      ])
    },
    {
      name  = "TS_STATE_DIR"
      value = "/var/lib/tailscale"
    },
    {
      name  = "TS_SOCKET"
      value = "/var/run/tailscale/tailscaled.sock"
    },
    {
      name  = "TS_HOSTNAME"
      value = coalesce(var.keycloak_admin_subdomain, module.this.id)
    },
    {
      name  = "TS_USERSPACE",
      value = "true"
    },
    {
      name  = "TS_SOCKS5_SERVER"
      value = "localhost:1055"
    },
    {
      name  = "TS_OUTBOUND_HTTP_PROXY_LISTEN"
      value = "localhost:1055"
    },
    {
      name  = "TS_LOCAL_ADDR_PORT"
      value = "0.0.0.0:${local.port_tailscale_healthcheck}"
    },
    {
      name  = "TS_ENABLE_METRICS"
      value = "true"
    },
    {
      name  = "TS_ENABLE_HEALTH_CHECK"
      value = "true"
    },
    {
      name  = "TS_SERVE_CONFIG"
      value = "/config/serve.json"
    }
  ]
  linux_parameters = { initProcessEnabled = true }
  log_configuration = {
    logDriver = "awslogs"
    options = {
      "awslogs-group"         = aws_cloudwatch_log_group.tailscale[0].name
      "awslogs-region"        = local.region
      "awslogs-stream-prefix" = "ecs"
    }
    secretOptions = null
  }
}
module "tailscale_ingress" {
  source  = "cloudposse/ecs-alb-service-task/aws"
  version = "0.76.1"

  vpc_id                             = var.vpc_id
  ecs_cluster_arn                    = module.ecs_cluster.arn
  security_group_ids                 = [aws_security_group.tailscale[0].id]
  security_group_enabled             = false
  subnet_ids                         = var.public_subnet_ids
  assign_public_ip                   = true
  ignore_changes_task_definition     = false
  exec_enabled                       = var.exec_enabled
  desired_count                      = 1
  deployment_maximum_percent         = 100 # we only want one at a time, to prevent tailscale nodes from stepping on eachother
  deployment_minimum_healthy_percent = 0
  task_cpu                           = 1024 # ref https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html
  task_memory                        = 2048

  container_definition_json = jsonencode([
    module.tailscale_def.json_map_object,
    module.tailscale_init_sidecar.json_map_object,
  ])

  bind_mount_volumes = [
    {
      name = "tailscale-config"
    }
  ]
  efs_volumes = [
    {
      host_path = null
      name      = "tailscale-state"
      efs_volume_configuration = [{
        host_path               = null
        file_system_id          = aws_efs_file_system.tailscale_state[0].id
        root_directory          = "/"
        transit_encryption      = "ENABLED"
        transit_encryption_port = local.port_efs_tailscale_state
        authorization_config = [
          {
            access_point_id = aws_efs_access_point.tailscale_state[0].id
            iam             = "DISABLED"
        }]
      }]

    }
  ]

  # the container uses service connect to be able to dynamically reference the keycloak containers by dns "keycloak-web"
  service_connect_configurations = [{
    enabled   = true
    namespace = aws_service_discovery_http_namespace.this[0].arn
    service   = []
  }]

  context = module.label_tailscale.context
}


resource "aws_iam_role_policy_attachment" "tailscale_exec" {
  role       = module.tailscale_ingress.task_exec_role_name
  policy_arn = aws_iam_policy.tailscale_exec.arn
}

resource "aws_iam_policy" "tailscale_exec" {
  name   = "${module.label_tailscale.id}-ecs-execution"
  policy = data.aws_iam_policy_document.tailscale_exec.json
}

data "aws_iam_policy_document" "tailscale_exec" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "kms:Decrypt",
      "elasticfilesystem:ClientMount",
      "elasticfilesystem:ClientWrite",
      "elasticfilesystem:DescribeMountTargets",
      "elasticfilesystem:DescribeFileSystems"

    ]
    resources = [
      aws_secretsmanager_secret.authkey[0].arn,
      local.kms_key_arn,
      aws_efs_file_system.tailscale_state[0].arn
    ]
  }
}

#
resource "aws_iam_role_policy_attachment" "tailscale_task" {
  count      = module.this.enabled ? 1 : 0
  role       = module.tailscale_ingress.task_role_name
  policy_arn = aws_iam_policy.tailscale_task[0].arn
}

resource "aws_iam_policy" "tailscale_task" {
  count  = module.this.enabled ? 1 : 0
  name   = "${module.label_tailscale.id}-ecs-task"
  policy = data.aws_iam_policy_document.tailscale_task.json
}

data "aws_iam_policy_document" "tailscale_task" {

  statement {
    effect = "Allow"
    actions = [
      "ssm:GetParameters",
      "ssm:GetParameter",
      "ssm:PutParameters",
      "ssm:PutParameter",
      "kms:Decrypt",
      "kms:Encrypt",
    ]
    resources = [
      local.kms_key_arn
    ]
  }
}
