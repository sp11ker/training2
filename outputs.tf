output "ec2_instances_public_ips" {
  description = "Public IPs of all EC2 instances mapped by name"
  value = {
    for name, instance in aws_instance.ec2 :
    name => instance.public_ip
  }
}

output "private_key_pem" {
  value     = tls_private_key.example.private_key_pem
  sensitive = true
}
