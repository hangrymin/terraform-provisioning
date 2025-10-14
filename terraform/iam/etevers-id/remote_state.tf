data "terraform_remote_state" "kms" {
  count   = var.enable_remote_state ? 1 : 0
  backend = "s3"
  config = merge(
    var.remote_state.kms["etevers-id"].apne2,
    {
      assume_role = {
        role_arn = var.assume_role_arn
      }
    }
  )
}

data "terraform_remote_state" "secretsmanager" {
  count   = var.enable_remote_state ? 1 : 0
  backend = "s3"
  config = merge(
    var.remote_state.secretsmanager["etevers-id"].apne2,
    {
      assume_role = {
        role_arn = var.assume_role_arn
      }
    }
  )
}

data "terraform_remote_state" "demo_tmcdapne2" {
  count   = var.enable_remote_state ? 1 : 0
  backend = "s3"
  config = merge(
    var.remote_state.ecs.demo.tmcdapne2,
    {
      assume_role = {
        role_arn = var.assume_role_arn
      }
    }
  )
}

data "terraform_remote_state" "codedeploy" {
  count   = var.enable_remote_state ? 1 : 0
  backend = "s3"
  config = merge(
    var.remote_state.codedeploy["etevers-id"].apne2,
    {
      assume_role = {
        role_arn = var.assume_role_arn
      }
    }
  )
}

data "terraform_remote_state" "eks" {
  count   = var.enable_remote_state ? 1 : 0
  backend = "s3"
  config = merge(
    var.remote_state.eks["tmcdapne2-nhwy"],
    {
      assume_role = {
        role_arn = var.assume_role_arn
      }
    }
  )
}

locals {
  kms_outputs            = var.enable_remote_state ? data.terraform_remote_state.kms[0].outputs : {}
  secretsmanager_outputs = var.enable_remote_state ? data.terraform_remote_state.secretsmanager[0].outputs : {}
  # 필요하면 demo/eks/codedeploy도 같은 식으로 추가
}
