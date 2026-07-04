resource "aws_acm_certificate" "playlist_manager_ssl_cert" {
  domain_name               = var.root_domain_name
  validation_method         = "DNS"
  subject_alternative_names = ["*.${var.root_domain_name}"]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn         = aws_acm_certificate.playlist_manager_ssl_cert.arn
  validation_record_fqdns = var.validation_record_fqdns
}
