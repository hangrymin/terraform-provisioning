resource "aws_iam_role" "demo_tmcdapne2_task" {
  name               = "demo-tmcdapne2-task"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.demo_tmcdapne2_task_assume_role_document.json
}

data "aws_iam_policy_document" "demo_tmcdapne2_task_assume_role_document" {
  statement {
    effect = "Allow"
    principals {
      identifiers = ["ecs-tasks.amazonaws.com"]
      type        = "Service"
    }
    actions = ["sts:AssumeRole"]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = ["066346343248"]
    }
    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:ecs:ap-northeast-2:066346343248:*"]
    }
  }
}

# 원격 state 값이 준비된 것만 사용
locals {
  demo_task_kms_resources = var.enable_remote_state ? compact([try(local.kms_outputs.aws_kms_key_apne2_deployment_common_arn, "")]) : []
  demo_task_sm_resources  = var.enable_remote_state ? compact([try(local.secretsmanager_outputs.aws_secretsmanager_demo_tmcdapne2_id, "")]) : []
}

data "aws_iam_policy_document" "demo_kms_ssm_document" {
  # KMS statement: 리소스가 있을 때만 포함
  dynamic "statement" {
    for_each = length(local.demo_task_kms_resources) > 0 ? [1] : []
    content {
      sid       = "AllowToDecryptKMSKey"
      effect    = "Allow"
      actions   = ["kms:Decrypt"]
      resources = local.demo_task_kms_resources
    }
  }

  # Secrets Manager statement: 리소스가 있을 때만 포함
  dynamic "statement" {
    for_each = length(local.demo_task_sm_resources) > 0 ? [1] : []
    content {
      sid       = "AllowSecretsManagerAccess"
      effect    = "Allow"
      actions   = ["secretsmanager:GetSecretValue"]
      resources = local.demo_task_sm_resources
    }
  }
}

# 둘 다 없으면 정책 리소스 자체를 만들지 않음
resource "aws_iam_role_policy" "demo_kms" {
  count  = (length(local.demo_task_kms_resources) + length(local.demo_task_sm_resources)) > 0 ? 1 : 0
  name   = "demo-kms-decryption"
  role   = aws_iam_role.demo_tmcdapne2_task.id
  policy = data.aws_iam_policy_document.demo_kms_ssm_document.json
}

output "demo_tmcdapne2_task_arn" {
  value = aws_iam_role.demo_tmcdapne2_task.arn
}
