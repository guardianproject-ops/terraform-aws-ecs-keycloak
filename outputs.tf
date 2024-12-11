output "kms_key_arn" {
  value       = local.kms_key_arn
  description = "The KMS Key ARN used for this deployment"
}

output "cloudwatch_log_group_keycloak" {
  description = "All outputs from `aws_cloudwatch_log_group.keycloak`"
  value       = aws_cloudwatch_log_group.keycloak
}

output "cloudwatch_log_group_arn_keycloak" {
  description = "Cloudwatch log group ARN for keycloak"
  value       = join("", aws_cloudwatch_log_group.keycloak[*].arn)
}

output "cloudwatch_log_group_name_keycloak" {
  description = "Cloudwatch log group name for keycloak"
  value       = join("", aws_cloudwatch_log_group.keycloak[*].name)
}

output "cloudwatch_log_group_tailscale" {
  description = "All outputs from `aws_cloudwatch_log_group.tailscale`"
  value       = module.service_tailscale.cloudwatch_log_group_tailscale
}

output "cloudwatch_log_group_arn_tailscale" {
  description = "Cloudwatch log group ARN for tailscale"
  value       = module.service_tailscale.cloudwatch_log_group_arn_tailscale
}

output "cloudwatch_log_group_name_tailscale" {
  description = "Cloudwatch log group name for tailscale"
  value       = module.service_tailscale.cloudwatch_log_group_name_tailscale
}

output "keycloak_password" {
  value = random_password.keycloak_password[0].result
}

output "alb" {
  value = module.alb
}

output "secrets_manager_secret_authkey_arn" {
  value = module.service_tailscale.secrets_manager_secret_authkey_arn
}

output "secrets_manager_secret_authkey_id" {
  value = module.service_tailscale.secrets_manager_secret_authkey_id
}
