output "dev_crm_public_ip" {
  value = aws_instance.dev_crm.public_ip
}

output "dev_db_public_ip" {
  value = aws_instance.dev_db.public_ip
}

output "prod_crm_public_ip" {
  value = aws_instance.prod_crm.public_ip
}

output "prod_db_public_ip" {
  value = aws_instance.prod_db.public_ip
}

output "private_key_pem" {
  value     = tls_private_key.example.private_key_pem
  sensitive = true
}

resource "local_file" "private_key" {
  content         = tls_private_key.example.private_key_pem
  filename        = "${path.module}/my-keypair.pem"
  file_permission = "0400"
}
