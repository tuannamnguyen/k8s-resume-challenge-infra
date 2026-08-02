output "secret_arn" {
  description = "ARN of the secret"
  value       = module.secrets_manager.secret_arn
}
