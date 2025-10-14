#
# zerone-id administrator
#
resource "aws_iam_role" "assume_id_admin" {
  provider = aws.bootstrap
  name                 = "assume-id-admin"
  path                 = "/"
  max_session_duration = "43200"
  assume_role_policy   = data.aws_iam_policy_document.assume_id_admin_assume_role.json
}

data "aws_iam_policy_document" "assume_id_admin_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type = "AWS"
      identifiers = [
        # ① 무권한 사용자: etevers
        "arn:aws:iam::763940551622:user/etevers",
        # ② 지금 Terraform 실행 주체(현재 그대로 계속 쓰려면 포함)
        "arn:aws:iam::763940551622:user/chatbot-admin-partner"
        # 필요 없다면 위 ②는 나중에 제거 가능
      ]
    }

      # (선택) MFA 강제 예시 — 원할 때만 주석 해제
    # condition {
    #   test     = "Bool"
    #   variable = "aws:MultiFactorAuthPresent"
    #   values   = ["true"]
    # }
  }
}

resource "aws_iam_role_policy" "assume_id_admin_passrole" {
  provider = aws.bootstrap
  name     = "assume-id-admin-passrole"
  role     = aws_iam_role.assume_id_admin.id
  policy   = data.aws_iam_policy_document.assume_id_admin_pass_role.json
}

data "aws_iam_policy_document" "assume_id_admin_pass_role" {
  statement {
    actions = ["iam:PassRole"]
    effect  = "Allow"
    resources = ["*"]
  }
}

# Admin 권한 부여
resource "aws_iam_role_policy_attachment" "assume_id_admin" {
  provider  = aws.bootstrap
  role       = aws_iam_role.assume_id_admin.id
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}