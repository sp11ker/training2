locals {
  company_tag = {
    company = "acme financing"
  }

  env_tags = {
    it   = merge(local.company_tag, { env = "it" })
    dev  = merge(local.company_tag, { env = "dev" })
    prod = merge(local.company_tag, { env = "prod" })
  }

  # Define project tags for EC2s only
  project_tag = {
    it   = { project = "management" }
    dev  = { project = "finance" }
    prod = { project = "finance" }
  }

  # Define role tags per instance (per VPC)
  ec2_roles = {
    it = {
      it_instance_1 = "admin"
      it_instance_2 = "backup"
    }
    dev = {
      dev_instance_1 = "web"
      dev_instance_2 = "db"
    }
    prod = {
      prod_instance_1 = "web"
      prod_instance_2 = "db"
    }
  }

  # A reusable function-like local to generate EC2 tags
  ec2_tags = {
    for vpc_name, instances in local.ec2_roles :
    vpc_name => {
      for instance_name, role in instances :
      instance_name => merge(
        local.env_tags[vpc_name],
        local.project_tag[vpc_name],
        { role = role }
      )
    }
  }
}
