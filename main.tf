data "aws_region" "this" {}
data "aws_caller_identity" "this" {}
locals {
  region                            = data.aws_region.this.name
  create_kms_key                    = var.kms_key_arn == null ? true : false
  kms_key_arn                       = var.kms_key_arn == null ? module.kms_key.key_arn : var.kms_key_arn
  deletion_protection_enabled       = var.deletion_protection_enabled
  keycloak_cluster_s3_bucket_name   = aws_s3_bucket.keycloak_clustering[0].id
  keycloak_cluster_s3_bucket_arn    = aws_s3_bucket.keycloak_clustering[0].arn
  keycloak_cluster_s3_bucket_prefix = "jgroups/${module.this.id}"
  jvm_heap_max                      = var.jvm_heap_max != null ? var.jvm_heap_max : 0.75 * var.task_memory
  java_opts_list = concat([
    "-XX:+DisableExplicitGC",
    "-XX:+UseG1GC",
    "-Xms${var.jvm_heap_min}m",
    "-Xmx${local.jvm_heap_max}m",
    "-XX:MetaspaceSize=${var.jvm_meta_min}m",
    "-XX:MaxMetaspaceSize=${var.jvm_meta_max}m",
    "-Djava.net.preferIPv4Stack=true",
    "-Djava.net.preferIPv4Addresses",
    "-Djava.security.egd=file:/dev/urandom",
    "-Dnashorn.args=--no-deprecation-warning",
    "-Djava.net.preferIPv4Stack=true",
  ], var.java_opts_extra)
  rds_master_user_secret_arn = var.rds_master_user_secret_arn
  rds_master_username        = var.rds_master_username
  java_opts                  = join(" ", local.java_opts_list)
  db_addr                    = var.db_keycloak_host
  db_port                    = var.db_keycloak_port
  #rds_iam_url                 = "jdbc:aws-wrapper:postgresql://${local.db_addr}:${local.db_port}/${var.db_keycloak_name}?wrapperPlugins=iam&ssl=true&sslmode=require"
  rds_iam_url                = var.rds_iam_auth_enabled ? "jdbc:aws-wrapper:postgresql://${local.db_addr}:${local.db_port}/${var.db_keycloak_name}?wrapperPlugins=iam&ssl=true&sslmode=verify-full&sslrootcert=/opt/keycloak/rds-global-bundle.pem" : ""
  rds_iam_user_arn           = var.rds_iam_auth_enabled ? "arn:aws:rds-db:${data.aws_region.this.name}:${data.aws_caller_identity.this.account_id}:dbuser:${var.rds_resource_id}/${var.db_keycloak_user}" : null
  db_url                     = var.rds_iam_auth_enabled ? local.rds_iam_url : "jdbc:postgresql://${local.db_addr}:${local.db_port}/${var.db_keycloak_name}"
  port_efs_tailscale_state   = var.port_efs_tailscale_state
  port_keycloak_cluster      = var.port_keycloak_cluster
  port_keycloak_web          = var.port_keycloak_web
  port_keycloak_management   = var.port_keycloak_management
  port_tailscale_healthcheck = var.port_tailscale_healthcheck
}
resource "aws_s3_bucket" "keycloak_clustering" {
  count  = module.this.enabled ? 1 : 0
  bucket = "${module.this.id}-keycloak-cluster"
  tags   = module.this.tags
}

resource "aws_s3_bucket_public_access_block" "keycloak_clustering" {
  count  = module.this.enabled ? 1 : 0
  bucket = aws_s3_bucket.keycloak_clustering[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


module "kms_key" {
  source                  = "cloudposse/kms-key/aws"
  version                 = "0.12.2"
  context                 = module.this.context
  enabled                 = local.create_kms_key == true ? true : false
  description             = "KMS Key for ${module.this.id} deployment"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  alias                   = "alias/${module.this.id}"
}

################
# Secrets
################

# This is the TLS cert+key that ALB uses to communicate with keycloak. It is self-signed.
# Because the load balancer, and its targets are in a virtual private cloud
# (VPC), traffic between the load balancer and the targets is authenticated at
# the packet level, so it is not at risk of man-in-the-middle attacks or
# spoofing even if the certificates on the targets are not valid.
# Therefore, we can use self-signed certificates or certificates that have expired.
# ref : https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-target-groups.html#target-group-routing-configuration

resource "tls_private_key" "keycloak" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_self_signed_cert" "keycloak" {
  private_key_pem = tls_private_key.keycloak.private_key_pem
  subject {
    common_name  = module.this.id
    organization = "Guardian Project Ops"
  }
  validity_period_hours = 12
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "random_password" "keycloak_password" {
  count   = module.this.enabled ? 1 : 0
  length  = 32
  special = false
}

module "label_ssm_params" {
  source     = "cloudposse/label/null"
  version    = "0.25.0"
  delimiter  = "/"
  attributes = ["keycloak"]
  context    = module.this.context
}

module "label_ssm_params_tailscale" {
  source     = "cloudposse/label/null"
  version    = "0.25.0"
  delimiter  = "/"
  attributes = ["tailscale"]
  context    = module.this.context
}

resource "aws_ssm_parameter" "keycloak_password" {
  count       = module.this.enabled ? 1 : 0
  name        = "/${module.label_ssm_params.id}/KEYCLOAK_PASSWORD"
  description = "keycloak_admin password for ${module.this.id}"
  tags        = module.this.tags
  type        = "SecureString"
  value       = random_password.keycloak_password[0].result
  key_id      = local.kms_key_arn
}


resource "aws_ssm_parameter" "keycloak_tls_cert" {
  count       = module.this.enabled ? 1 : 0
  name        = "/${module.label_ssm_params.id}/KEYCLOAK_TLS_CERT_B64"
  description = "tls certificate for keycloak's private HTTPS listener  ${module.this.id}"
  tags        = module.this.tags
  type        = "SecureString"
  value       = base64encode(tls_self_signed_cert.keycloak.cert_pem)
  key_id      = local.kms_key_arn
}

resource "aws_ssm_parameter" "keycloak_tls_key" {
  count       = module.this.enabled ? 1 : 0
  name        = "/${module.label_ssm_params.id}/KEYCLOAK_TLS_KEY_B64"
  description = "tls key for keycloak's private HTTPS listener  ${module.this.id}"
  tier        = "Advanced"
  tags        = module.this.tags
  type        = "SecureString"
  value       = base64encode(tls_private_key.keycloak.private_key_pem)
  key_id      = local.kms_key_arn
}


################
# ALB
################
module "label_alb" {
  source     = "cloudposse/label/null"
  version    = "0.25.0"
  attributes = ["alb"]
  context    = module.this.context
}

module "alb" {
  source             = "cloudposse/alb/aws"
  version            = "2.2.0"
  context            = module.label_alb.context
  vpc_id             = var.vpc_id
  security_group_ids = [aws_security_group.alb[0].id]
  subnet_ids         = var.public_subnet_ids

  ip_address_type = "ipv4"
  http_enabled    = true
  https_enabled   = true
  http2_enabled   = true
  #http_redirect               = true
  access_logs_enabled                     = true
  http_ingress_cidr_blocks                = ["0.0.0.0/0"]
  https_ingress_cidr_blocks               = ["0.0.0.0/0"]
  certificate_arn                         = var.keycloak_acm_certificate_arn
  deletion_protection_enabled             = local.deletion_protection_enabled
  health_check_path                       = "/"
  health_check_timeout                    = 30
  health_check_healthy_threshold          = 3
  health_check_unhealthy_threshold        = 3
  health_check_interval                   = 60
  health_check_matcher                    = "200-499"
  health_check_port                       = local.port_keycloak_management
  alb_access_logs_s3_bucket_force_destroy = !local.deletion_protection_enabled
}

################
# ECS CLUSTER
################

module "ecs_cluster" {
  source                          = "cloudposse/ecs-cluster/aws"
  version                         = "0.9.0"
  context                         = module.this.context
  enabled                         = module.this.enabled
  container_insights_enabled      = true
  capacity_providers_fargate      = true
  capacity_providers_fargate_spot = false
  kms_key_id                      = local.kms_key_arn
}


################
# CLOUDWATCH
################

module "label_log_group_keycloak" {
  source     = "cloudposse/label/null"
  version    = "0.25.0"
  delimiter  = "/"
  attributes = ["keycloak"]
  context    = module.this.context
}

module "label_log_group_tailscale" {
  source     = "cloudposse/label/null"
  version    = "0.25.0"
  delimiter  = "/"
  attributes = ["tailscale"]
  context    = module.this.context
}

module "label_log_group_secrets_init" {
  source     = "cloudposse/label/null"
  version    = "0.25.0"
  delimiter  = "/"
  attributes = ["secrets-init"]
  context    = module.this.context
}

module "label_log_group_tailscale_init" {
  source     = "cloudposse/label/null"
  version    = "0.25.0"
  delimiter  = "/"
  attributes = ["tailscale-init"]
  context    = module.this.context
}

module "label_log_group_postgres_init" {
  source     = "cloudposse/label/null"
  version    = "0.25.0"
  delimiter  = "/"
  attributes = ["postgres-init"]
  context    = module.this.context
}

resource "aws_cloudwatch_log_group" "keycloak" {
  count             = module.this.enabled ? 1 : 0
  name              = "/${module.label_log_group_keycloak.id}"
  retention_in_days = var.log_group_retention_in_days
  tags              = module.this.tags
}

resource "aws_cloudwatch_log_group" "tailscale" {
  count             = module.this.enabled ? 1 : 0
  name              = "/${module.label_log_group_tailscale.id}"
  retention_in_days = var.log_group_retention_in_days
  tags              = module.this.tags
}

resource "aws_cloudwatch_log_group" "secrets_init" {
  count             = module.this.enabled ? 1 : 0
  name              = "/${module.label_log_group_secrets_init.id}"
  retention_in_days = var.log_group_retention_in_days
  tags              = module.this.tags
}

resource "aws_cloudwatch_log_group" "tailscale_init" {
  count             = module.this.enabled ? 1 : 0
  name              = "/${module.label_log_group_tailscale_init.id}"
  retention_in_days = var.log_group_retention_in_days
  tags              = module.this.tags
}

resource "aws_cloudwatch_log_group" "postgres_init" {
  count             = module.this.enabled ? 1 : 0
  name              = "/${module.label_log_group_postgres_init.id}"
  retention_in_days = var.log_group_retention_in_days
  tags              = module.this.tags
}
resource "aws_service_discovery_http_namespace" "this" {
  count       = module.this.enabled ? 1 : 0
  name        = module.this.id
  description = "The service discovery namespace for ${module.this.id}"
  tags        = module.this.tags
}
