# This is ECS service that runs keycloak itself
module "label_keycloak" {
  source     = "cloudposse/label/null"
  version    = "0.25.0"
  context    = module.this.context
  attributes = ["keycloak"]
}

locals {
  keycloak_environment = [
    # ref all options: https://www.keycloak.org/server/all-config
    {
      name  = "KC_HTTPS_CERTIFICATE_FILE"
      value = "/secrets/server.crt.pem"
    },
    {
      name  = "KC_HTTPS_CERTIFICATE_KEY_FILE"
      value = "/secrets/server.key.pem"
    },
    {
      name  = "KC_HTTPS_CERTIFICATES_RELOAD_PERIOD"
      value = "-1"
    },
    {
      name  = "KC_DB_PASSWORD"
      value = var.rds_iam_auth_enabled ? null : var.db_keycloak_password
    },
    {
      name = "KC_DB_URL"
      # useful to add the connection query param wrapperLoggerLevel=finest
      value = local.db_url
    },
    {
      name  = "KC_DB_ADDR"
      value = local.db_addr
    },
    {
      name  = "KC_DB_USERNAME"
      value = var.db_keycloak_user
    },
    {
      name  = "KC_DB_SCHEMA"
      value = "public"
    },
    {
      # username for the temporary keycloak admin used to bootstrpa the instance
      name  = "KEYCLOAK_ADMIN"
      value = var.keycloak_admin_username
    },
    {
      name  = "KC_HOSTNAME_STRICT"
      value = "false"
    },
    # Why do we dynamically resolve the hostnames?
    # Because we want the admin host name to be dynamic, and in keycloak 26.0 w/ hostname v2, you
    # cannot configure the hostname to be fixed while having the admin-hostname dynamic
    #{
    #  # URL at which is the server exposed.
    #  name  = "KC_HOSTNAME"
    #  value = "https://${var.keycloak_domain}"
    #},
    #{
    #  # URL for accessing the administration console.
    #  name  = "KC_HOSTNAME_ADMIN"
    #  value = "https://${module.this.id}.${var.tailscale_domain}"
    #},
    {
      # ref: https://www.keycloak.org/server/reverseproxy#_configure_the_reverse_proxy_headers
      # ref: https://www.keycloak.org/server/all-config#option-extended-proxy-headers
      name  = "KC_PROXY_HEADERS"
      value = "xforwarded" # AWS ALB only does xforwarded
    },
    {
      # ref: https://www.keycloak.org/server/all-config#option-extended-proxy-trusted-addresses
      # ref: https://www.keycloak.org/server/reverseproxy#_trusted_proxies
      name  = "KC_PROXY_TRUSTED_ADDRESSES"
      value = join(",", var.public_subnet_cidrs)
    },
    {
      # ref: https://www.keycloak.org/server/all-provider-config#_sticky_session_encoder
      # ref: https://github.com/keycloak/keycloak/discussions/8692
      #      we use variant B described there
      name  = "KC_SPI_STICKY_SESSION_ENCODER_INFINISPAN_SHOULD_ATTACH_ROUTE"
      value = "false"
    },
    {
      # this file is in /opt/keycloak/conf and is built in to our docker image
      name  = "KC_CACHE_CONFIG_FILE"
      value = "cache-ispn-s3.xml"
    },
    {
      name  = "S3_PING_REGION_NAME"
      value = local.region
    },
    {
      name  = "S3_PING_BUCKET_NAME"
      value = local.keycloak_cluster_s3_bucket_name
    },
    {
      name  = "S3_PING_BUCKET_PREFIX"
      value = local.keycloak_cluster_s3_bucket_prefix
    },
    {
      name  = "S3_PING_KMS_KEY_ID"
      value = local.kms_key_arn
    },
    {
      name  = "KC_CACHE_STACK"
      value = "" # left blank intentionally
    },
    {
      name  = "KC_HTTP_MANAGEMENT_PORT"
      value = local.port_keycloak_management
    },
    {
      name  = "JAVA_OPTS"
      value = local.java_opts

    },
    {
      name = "KC_LOG_LEVEL"
      # during debug
      #value = "DEBUG,org.infinispan:ERROR,org.jgroups:ERROR,software.amazon.jdbc:INFO,io.netty:INFO,io.vertx.ext.web.impl:TRACE,org.hibernate:INFO,org.jgroups.protocols.aws:TRACE"
      # normal setting
      value = "INFO,org.infinispan:ERROR,org.jgroups:ERROR,org.jgroups.protocols.aws:INFO"
    },


  ]
}

# This is the container definition for keycloak
module "keycloak_def" {
  source  = "cloudposse/ecs-container-definition/aws"
  version = "0.61.1"

  container_name  = "keycloak"
  container_image = var.keycloak_container_image
  essential       = true

  mount_points = [
    {
      containerPath = "/secrets"
      readOnly      = true
      sourceVolume  = "keycloak-secrets"
    }
  ]

  container_depends_on = [
    {
      condition     = "SUCCESS"
      containerName = "secrets-init"
    }
  ]

  secrets = [
    {
      # password for the temporary keycloak admin used to bootstrpa the instance
      name      = "KEYCLOAK_ADMIN_PASSWORD"
      valueFrom = aws_ssm_parameter.keycloak_password[0].arn
    }
  ]

  port_mappings = [
    {
      name          = "keycloak-web"
      protocol      = "tcp",
      containerPort = local.port_keycloak_web
      hostPort      = local.port_keycloak_web
    },
    {
      name          = "keycloak-cluster"
      protocol      = "tcp",
      containerPort = local.port_keycloak_cluster
      hostPort      = local.port_keycloak_cluster
    },
    {
      name          = "keycloak-management"
      protocol      = "tcp",
      containerPort = local.port_keycloak_management
      hostPort      = local.port_keycloak_management
    },
  ]
  environment      = [for each in local.keycloak_environment : each if each.value != null]
  linux_parameters = { initProcessEnabled = true }
  log_configuration = {
    logDriver = "awslogs"
    options = {
      "awslogs-group"         = aws_cloudwatch_log_group.keycloak[0].name
      "awslogs-region"        = local.region
      "awslogs-stream-prefix" = "ecs"
    }
    secretOptions = null
  }
}

locals {
  container_def_postgres_init = {
    container_definition = module.postgres_init_sidecar[0].json_map_encoded
    condition            = "SUCCESS"
  }

  container_def_secrets_init = {
    container_definition = module.secrets_init_sidecar.json_map_encoded
    condition            = "SUCCESS"
  }
}

module "keycloak" {
  source  = "guardianproject-ops/ecs-web-app/aws"
  version = "0.0.1"

  launch_type            = "FARGATE"
  vpc_id                 = var.vpc_id
  use_alb_security_group = true

  container_name       = "keycloak"
  container_definition = module.keycloak_def.json_map_encoded
  container_port       = local.port_keycloak_web
  task_cpu             = var.task_cpu
  task_memory          = var.task_memory
  desired_count        = var.keycloak_node_count

  init_containers = concat(
    var.rds_init_keycloak_db ? [local.container_def_postgres_init] : [],
    [local.container_def_secrets_init]
  )

  bind_mount_volumes = [
    {
      name = "keycloak-secrets"
    }
  ]


  exec_enabled                                    = var.exec_enabled
  ecs_alarms_enabled                              = false
  ecs_cluster_arn                                 = module.ecs_cluster.arn
  ecs_cluster_name                                = module.ecs_cluster.name
  ecs_security_group_ids                          = [aws_security_group.keycloak[0].id]
  ecs_private_subnet_ids                          = var.public_subnet_ids
  assign_public_ip                                = true
  ignore_changes_task_definition                  = false
  alb_security_group                              = module.alb.security_group_id
  alb_target_group_alarms_enabled                 = true
  alb_target_group_alarms_3xx_threshold           = 25
  alb_target_group_alarms_4xx_threshold           = 25
  alb_target_group_alarms_5xx_threshold           = 25
  alb_target_group_alarms_response_time_threshold = 0.5
  alb_target_group_alarms_period                  = 300
  alb_target_group_alarms_evaluation_periods      = 1
  alb_arn_suffix                                  = module.alb.alb_arn_suffix
  alb_ingress_health_check_path                   = "/health/ready"
  alb_ingress_health_check_port                   = local.port_keycloak_management
  alb_ingress_health_check_timeout                = 30
  alb_ingress_health_check_interval               = 60
  alb_ingress_health_check_protocol               = "HTTPS"
  alb_ingress_protocol                            = "HTTPS"
  health_check_grace_period_seconds               = 120
  # All paths are unauthenticated by default
  # Without authentication, both HTTP and HTTPS endpoints are supported
  alb_ingress_unauthenticated_listener_arns = [
    module.alb.http_listener_arn,
    module.alb.https_listener_arn,
  ]
  # ref: https://www.keycloak.org/server/reverseproxy#_exposed_path_recommendations
  alb_ingress_unauthenticated_paths = ["/realms", "/resources", "/robots.txt"]
  alb_stickiness_cookie_duration    = 24 * 60 * 60
  alb_stickiness_enabled            = true
  alb_stickiness_type               = "app_cookie"
  alb_stickiness_cookie_name        = "AUTH_SESSION_ID"

  service_connect_configurations = [{
    enabled   = true
    namespace = aws_service_discovery_http_namespace.this[0].arn
    service = [{
      discovery_name = "keycloak-web"
      port_name      = "keycloak-web"
      client_alias = [{
        dns_name = "keycloak-web"
        port     = local.port_keycloak_web
      }]
      },
      {
        discovery_name = "keycloak-management"
        port_name      = "keycloak-management"
        client_alias = [{
          dns_name = "keycloak-management"
          port     = local.port_keycloak_management
        }]
      }
    ]
  }]


  alb_target_group_alarms_alarm_actions             = var.alarms_sns_topics_arns
  alb_target_group_alarms_ok_actions                = var.alarms_sns_topics_arns
  alb_target_group_alarms_insufficient_data_actions = var.alarms_sns_topics_arns
  ecs_alarms_cpu_utilization_high_alarm_actions     = var.alarms_sns_topics_arns
  ecs_alarms_cpu_utilization_high_ok_actions        = var.alarms_sns_topics_arns
  ecs_alarms_memory_utilization_high_alarm_actions  = var.alarms_sns_topics_arns
  ecs_alarms_memory_utilization_high_ok_actions     = var.alarms_sns_topics_arns

  context = module.label_keycloak.context
}

resource "aws_iam_role_policy_attachment" "keycloak_exec" {
  role       = module.keycloak.ecs_task_exec_role_name
  policy_arn = aws_iam_policy.keycloak_exec.arn
}

resource "aws_iam_policy" "keycloak_exec" {
  name   = "${module.label_keycloak.id}-read-ssm-params"
  policy = data.aws_iam_policy_document.keycloak_exec.json
}

data "aws_iam_policy_document" "keycloak_exec" {
  statement {
    effect = "Allow"
    actions = [
      "ssm:GetParameters",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "kms:Decrypt",
    ]
    resources = compact([
      aws_ssm_parameter.keycloak_password[0].arn,
      aws_secretsmanager_secret.authkey[0].arn,
      local.rds_master_user_secret_arn,
      aws_ssm_parameter.keycloak_tls_cert[0].arn,
      aws_ssm_parameter.keycloak_tls_key[0].arn,
      local.kms_key_arn
    ])
  }
}

resource "aws_iam_role_policy_attachment" "keycloak_task" {
  count      = module.this.enabled ? 1 : 0
  role       = module.keycloak.ecs_task_role_name
  policy_arn = aws_iam_policy.keycloak_task[0].arn
}

resource "aws_iam_policy" "keycloak_task" {
  count  = module.this.enabled ? 1 : 0
  name   = "${module.label_keycloak.id}-keycloak-task-perms"
  policy = data.aws_iam_policy_document.keycloak_task.json
}

data "aws_iam_policy_document" "keycloak_task_rds_iam" {

  statement {
    effect = "Allow"
    actions = [
      "rds-db:connect"
    ]
    resources = [
      local.rds_iam_user_arn
      #for debugging #"arn:aws:rds-db:*:*:dbuser:*/*"
    ]
  }
}


data "aws_iam_policy_document" "keycloak_task_s3_cluster" {



  statement {
    effect  = "Allow"
    actions = ["s3:ListBucket"]
    resources = [
      local.keycloak_cluster_s3_bucket_arn
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject"
    ]
    resources = [
      "${local.keycloak_cluster_s3_bucket_arn}/${local.keycloak_cluster_s3_bucket_prefix}/*"
    ]
  }
}

data "aws_iam_policy_document" "keycloak_task_secrets" {
  statement {
    effect = "Allow"
    actions = [
      "ssm:GetParameters",
      "ssm:GetParameter",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "kms:Decrypt",
    ]
    resources = [
      aws_ssm_parameter.keycloak_tls_cert[0].arn,
      aws_ssm_parameter.keycloak_tls_key[0].arn,
      local.kms_key_arn
    ]
  }
}

data "aws_iam_policy_document" "keycloak_task" {
  source_policy_documents = concat(
    [
      data.aws_iam_policy_document.keycloak_task_secrets.json,
      data.aws_iam_policy_document.keycloak_task_s3_cluster.json
    ],
    var.rds_iam_auth_enabled ? [data.aws_iam_policy_document.keycloak_task_rds_iam.json] : [],
  )
}
