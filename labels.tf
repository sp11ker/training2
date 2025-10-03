locals {
  company_tag = {
    Company = "Acme Financing"
  }

  env_tags = {
    it = merge(local.company_tag, {
      Env  = "it"
      Name = "it-vpc"
    })
    dev = merge(local.company_tag, {
      Env  = "dev"
      Name = "dev-vpc"
    })
    prod = merge(local.company_tag, {
      Env  = "prod"
      Name = "prod-vpc"
    })
  }

  ec2_tags = {
    it = {
      it_instance_1 = merge(local.env_tags["it"], {
        Role    = "admin"
        Project = "management"
        Name    = "it-admin"
      })
      it_instance_2 = merge(local.env_tags["it"], {
        Role    = "backup"
        Project = "management"
        Name    = "it-backup"
      })
    }

    dev = {
      dev_instance_1 = merge(local.env_tags["dev"], {
        Role    = "web"
        Project = "finance"
        Name    = "dev-web"
      })
      dev_instance_2 = merge(local.env_tags["dev"], {
        Role    = "db"
        Project = "finance"
        Name    = "dev-db"
      })
    }

    prod = {
      prod_instance_1 = merge(local.env_tags["prod"], {
        Role    = "web"
        Project = "finance"
        Name    = "prod-web"
        Security  = "high"
      })
      prod_instance_2 = merge(local.env_tags["prod"], {
        Role    = "db"
        Project = "finance"
        Name    = "prod-db"
        Security  = "high"
      })
    }
  }
}
