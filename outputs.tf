###############################
# EC2 Instance Public IPs (Dynamically by Name)
###############################

output "ec2_instances_public_ips" {
  value = {
    for instance in [
      aws_instance.it_instance_1,
      aws_instance.it_instance_2,
      aws_instance.dev_instance_1,
      aws_instance.dev_instance_2,
      aws_instance.prod_instance_1,
      aws_instance.prod_instance_2
    ] :
    instance.tags["Name"] => instance.public_ip
  }
}
