module "db_secrets" {
  source = "terraform-aws-modules/secrets-manager/aws"

  name                    = module.label.id
  recovery_window_in_days = 0

  tags = module.label.tags

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
    DB_USER = var.DB_USER
    DB_PASS = var.DB_PASS
  })
}
