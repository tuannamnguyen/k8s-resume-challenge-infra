output "validation_record_fqdns" {
  description = "FQDNs of validation records"
  value       = [for record in aws_route53_record.playlist_manager_cert_dns : record.fqdn]
}

output "nameservers" {
  description = "Nameservers of Route 53"
  value       = aws_route53_zone.playlist_manager_zone.name_servers
}
