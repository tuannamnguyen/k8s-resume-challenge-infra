output "db_secret_arn" {
  description = "ARN of the secret"
  value       = module.db_secrets.secret_arn
}
