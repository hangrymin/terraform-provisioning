###########AWS console에 etevers 생성용 ###########
# # --- 임시 부트스트랩용 (assume 없음) ---
# provider "aws" {
#   alias  = "bootstrap"
#   region = var.aws_region
# }

# # --- 임시 기본 provider도 assume 없음 ---
# provider "aws" {
#   region = var.aws_region
# }
#######################################

provider "aws" {
  alias  = "bootstrap"
  region = var.aws_region
}

provider "aws" {
  region = var.aws_region

  assume_role {
    role_arn     = var.assume_role_arn
    session_name = var.atlantis_user
  }
}
