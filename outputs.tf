output "ec2_instances_public_ips" {
  description = "Map of EC2 instance names to their public IP addresses"
  value = {
    for name, instance in aws_instance.ec2 :
    name => instance.public_ip
  }
}

output "private_key_pem" {
  description = "Private key PEM content"
  value     = tls_private_key.example.private_key_pem
  sensitive = true
}
