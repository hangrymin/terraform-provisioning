resource "aws_iam_role" "app_demoapp" {
  name = "app-demoapp"
  path = "/"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = { Service = "ec2.amazonaws.com" }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# 원격 state가 켜졌을 때만 안전하게 자원 목록 계산
locals {
  demoapp_kms_resources = var.enable_remote_state ? compact([try(local.kms_outputs.aws_kms_key_apne2_deployment_common_arn, "")]) : []
  demoapp_sm_resources  = var.enable_remote_state ? compact([try(local.secretsmanager_outputs.aws_secretsmanager_demo_tmcdapne2_id, "")]) : []
}

resource "aws_iam_role_policy" "demoapp_operation" {
  # 둘 다 비어 있으면 정책 자체를 만들지 않음 (빈 Statement/Resource 방지)
  count = (length(local.demoapp_kms_resources) + length(local.demoapp_sm_resources)) > 0 ? 1 : 0

  name = "minimum-demoapp-operation-access"
  role = aws_iam_role.app_demoapp.id

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = concat(
      length(local.demoapp_kms_resources) > 0 ? [{
        Sid      = "AllowToDecryptKMSKey"
        Effect   = "Allow"
        Action   = ["kms:Decrypt"]
        Resource = local.demoapp_kms_resources
      }] : [],
      length(local.demoapp_sm_resources) > 0 ? [{
        Sid      = "AllowSecretsManagerAccess"
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = local.demoapp_sm_resources
      }] : []
    )
  })
}

resource "aws_iam_instance_profile" "app_demoapp" {
  name = "demoapp-profile"
  role = aws_iam_role.app_demoapp.name
}

resource "aws_iam_role_policy_attachment" "demoapp_attach" {
  role       = aws_iam_role.app_demoapp.name
  policy_arn = aws_iam_policy.app_universal.arn
}

output "app_demoapp_instance_profile" {
  value = aws_iam_instance_profile.app_demoapp.arn
}
