# DEV Outputs
output "dev_web_public_ip" {
  value = aws_instance.web-dev.public_ip
}

output "dev_proc_public_ip" {
  value = aws_instance.proc-dev.public_ip
}

output "dev_db_public_ip" {
  value = aws_instance.db-dev.public_ip
}

# PROD Outputs
output "prod_web_public_ip" {
  value = aws_instance.web-prod.public_ip
}

output "prod_proc_public_ip" {
  value = aws_instance.proc-prod.public_ip
}

output "prod_db_public_ip" {
  value = aws_instance.db-prod.public_ip
}

# Private key output (sensitive)
output "private_key_pem" {
  value     = tls_private_key.example.private_key_pem
  sensitive = true
}
