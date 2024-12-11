module "tailscale_init_sidecar" {
  source  = "cloudposse/ecs-container-definition/aws"
  version = "0.61.1"

  container_name  = "tailscale-init"
  container_image = "public.ecr.aws/aws-cli/aws-cli:2.22.12"
  essential       = false

  mount_points = [
    {
      containerPath = "/state"
      readOnly      = false
      sourceVolume  = "tailscale-state"
    },
    {
      containerPath = "/config"
      readOnly      = false
      sourceVolume  = "tailscale-config"
    }
  ]
  entrypoint = ["/bin/bash"]
  command = [
    "-c",
    <<-EOT
    set -ex -o pipefail

    cat <<-EOF > /config/serve.json
    {
      "TCP": {
        "443": {
          "HTTPS": true
        }
      },
      "Web": {
        "\$${TS_CERT_DOMAIN}:443": {
          "Handlers": {
            "/": {
              "Proxy": "https+insecure://keycloak-web:${local.port_keycloak_web}"
            }
          }
        }
      },
      "AllowFunnel": {
        "\$${TS_CERT_DOMAIN}:443": false
      }
    }
    EOF
    ls -al /config/serve.json
    cat /config/serve.json
    EOT
  ]

  log_configuration = {
    logDriver = "awslogs"
    options = {
      "awslogs-region"        = local.region
      "awslogs-group"         = aws_cloudwatch_log_group.tailscale_init[0].name
      "awslogs-region"        = local.region
      "awslogs-stream-prefix" = "ecs"
    }
  }
}
