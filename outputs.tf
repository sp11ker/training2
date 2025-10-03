output "ec2_instances_public_ips" {
  description = "Public IP addresses of all EC2 instances"
  value = {
    for instance_name, instance in aws_instance.ec2 :
    instance_name => instance.public_ip
  }
}
