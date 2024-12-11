module "label_ts" {
  source     = "cloudposse/label/null"
  version    = "0.25.0"
  context    = module.this.context
  attributes = ["tailscale-rotate"]
}
#############################################################################
# Tailscale Auth key
resource "aws_secretsmanager_secret" "authkey" {
  count                   = module.label_ts.enabled ? 1 : 0
  name                    = "${module.label_ts.id}/tailscale-keycloak"
  recovery_window_in_days = 0
  tags                    = module.label_ts.tags
}

resource "aws_secretsmanager_secret_rotation" "authkey" {
  count               = module.label_ts.enabled ? 1 : 0
  secret_id           = aws_secretsmanager_secret.authkey[0].id
  rotation_lambda_arn = module.ts_rotate.lambda.lambda_function_arn

  rotation_rules {
    automatically_after_days = 3
  }
}

resource "aws_secretsmanager_secret_version" "authkey" {
  count     = module.label_ts.enabled ? 1 : 0
  secret_id = aws_secretsmanager_secret.authkey[0].id
  secret_string = jsonencode({
    "Type" : "auth-key",
    "Attributes" : {
      "key_request" : {
        "tags" : var.tailscale_tags_keycloak,
        "description" : "Auth key for Keycloak ECS ${module.label_ts.id}",
        # 3 days + 6 hours = so it is valid slightly longer than the secret in secrets manager
        "expiry_seconds" : (3 * 24 * 60 * 60) + 6 * 60 * 60,
        "reusable" : true,
        "ephemeral" : true
      }
  } })
  version_stages = ["TFINIT"]
  depends_on = [
    module.ts_rotate.lambda
  ]
}

#############################################################################
# Rotation Lambda
module "ts_rotate" {
  source           = "guardianproject-ops/lambda-secrets-manager-tailscale/aws"
  version          = "0.0.1"
  ts_client_secret = var.tailscale_client_secret
  ts_client_id     = var.tailscale_client_id
  tailnet          = var.tailscale_tailnet
  secret_prefix    = "${module.label_ts.id}/*"
  context          = module.label_ts.context
}
