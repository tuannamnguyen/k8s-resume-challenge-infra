output "domain_validation_option" {
  # https://docs.aws.amazon.com/acm/latest/userguide/dns-validation.html
  value       = aws_acm_certificate.playlist_manager_ssl_cert.domain_validation_options
  description = "ACM domains to prove controls of domain"
}
