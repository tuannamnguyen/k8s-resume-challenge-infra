module "secrets_manager" {
  source = "terraform-aws-modules/secrets-manager/aws"

  name_prefix             = var.project_name
  recovery_window_in_days = 0

  create_policy       = true
  block_public_policy = true
  policy_statements = {
    read = {
      sid = "AllowAccountRead"
      principals = [{
        type        = "AWS"
        identifiers = ["arn:aws:iam::${var.account_id}:root"]
      }]
      actions   = ["secretsmanager:GetSecretValue"]
      resources = ["*"]
    }
  }

  secret_string = jsonencode({
    env_keys = var.env_keys
    env_prod = var.env_prod
  })
}
