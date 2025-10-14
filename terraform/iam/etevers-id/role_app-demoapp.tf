resource "aws_iam_role" "app_demoapp" {
  name = "app-demoapp"
  path = "/"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Action" : "sts:AssumeRole",
      }
    ]
  })
}

resource "aws_iam_role_policy" "demoapp_operation" {
  name = "minimum-demoapp-operation-access"
  role = aws_iam_role.app_demoapp.id

  # enable_remote_state 가 true 일 때만 각 statement 를 포함하도록 구성
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      # 1) KMS Decrypt (remote_state 켜졌을 때만)
      var.enable_remote_state ? [
        {
          Sid    = "AllowToDecryptKMSKey"
          Effect = "Allow"
          Action = ["kms:Decrypt"]
          Resource = compact([
            try(local.kms_outputs.aws_kms_key_apne2_deployment_common_arn, "")
          ])
        }
      ] : [],

      # 2) Secrets Manager (remote_state 켜졌을 때만)
      var.enable_remote_state ? [
        {
          Sid    = "AllowSecretsManagerAccess"
          Effect = "Allow"
          Action = ["secretsmanager:GetSecretValue"]
          Resource = compact([
            try(local.secretsmanager_outputs.aws_secretsmanager_demo_tmcdapne2_id, "")
          ])
        }
      ] : []
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
