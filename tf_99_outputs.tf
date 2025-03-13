#==================================================================
# route53-record - outputs.tf
#==================================================================

output "record_id" {
  description = "O ID do Route 53 Record Set."
  value       = aws_route53_record.this.id
}

output "name" {
  description = "O nome do Route 53 Record Set."
  value       = aws_route53_record.this.name
}

output "fqdn" {
  description = "O FQDN: URL completa formada pelo Record Set e o Hosted Zone."
  value       = aws_route53_record.this.fqdn
}
