###########AWS console에 etevers 생성용 ###########
# --- bootstrap provider (assume 없음) ---
provider "aws" {
  alias  = "bootstrap"
  region = var.aws_region
}

# --- 임시 기본 provider: assume_role 주석 처리 ---
provider "aws" {
  region = var.aws_region
  # assume_role {
  #   role_arn     = var.assume_role_arn
  #   session_name = var.atlantis_user
  # }
}

#######################################

# provider "aws" {
#   alias  = "bootstrap"
#   region = var.aws_region
# }

# provider "aws" {
#   region = var.aws_region

#   assume_role {
#     role_arn     = var.assume_role_arn
#     session_name = var.atlantis_user
#   }
# }
