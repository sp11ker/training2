###############################
# EC2 Instance Public IPs (By Name)
###############################

output "ec2_instances_public_ips" {
  value = {
    # IT Instances
    local.ec2_tags["it"]["it_instance_1"].Name   => aws_instance.it_instance_1.public_ip,
    local.ec2_tags["it"]["it_instance_2"].Name   => aws_instance.it_instance_2.public_ip,

    # DEV Instances
    local.ec2_tags["dev"]["dev_instance_1"].Name => aws_instance.dev_instance_1.public_ip,
    local.ec2_tags["dev"]["dev_instance_2"].Name => aws_instance.dev_instance_2.public_ip,

    # PROD Instances
    local.ec2_tags["prod"]["prod_instance_1"].Name => aws_instance.prod_instance_1.public_ip,
    local.ec2_tags["prod"]["prod_instance_2"].Name => aws_instance.prod_instance_2.public_ip,
  }
}

###############################
# Individual Public IP Outputs (Optional)
###############################

output "it_instance_1_public_ip" {
  value = aws_instance.it_instance_1.public_ip
}

output "it_instance_2_public_ip" {
  value = aws_instance.it_instance_2.public_ip
}

output "dev_instance_1_public_ip" {
  value = aws_instance.dev_instance_1.public_ip
}

output "dev_instance_2_public_ip" {
  value = aws_instance.dev_instance_2.public_ip
}

output "prod_instance_1_public_ip" {
  value = aws_instance.prod_instance_1.public_ip
}

output "prod_instance_2_public_ip" {
  value = aws_instance.prod_instance_2.public_ip
}

###############################
# Private Key Output (Sensitive)
###############################

output "private_key_pem" {
  value     = tls_private_key.example.private_key_pem
  sensitive = true
}
