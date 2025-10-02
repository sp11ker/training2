###############################
# DEV Outputs
###############################

output "dev_instance_1_public_ip" {
  value = aws_instance.dev_instance_1.public_ip
}

output "dev_instance_2_public_ip" {
  value = aws_instance.dev_instance_2.public_ip
}

###############################
# PROD Outputs
###############################

output "prod_instance_1_public_ip" {
  value = aws_instance.prod_instance_1.public_ip
}

output "prod_instance_2_public_ip" {
  value = aws_instance.prod_instance_2.public_ip
}

###############################
# IT Outputs
###############################

output "it_instance_1_public_ip" {
  value = aws_instance.it_instance_1.public_ip
}

output "it_instance_2_public_ip" {
  value = aws_instance.it_instance_2.public_ip
}

###############################
# Private Key Output (Sensitive)
###############################

output "private_key_pem" {
  value     = tls_private_key.example.private_key_pem
  sensitive = true
}
