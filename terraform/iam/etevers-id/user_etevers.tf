# 무권한 사용자
resource "aws_iam_user" "etevers" {
  provider = aws.bootstrap
  name     = "etevers"
  path     = "/"
}

# etevers → assume-id-admin Role 로 Assume 허용 (최소 권한)
resource "aws_iam_user_policy" "etevers_sts_assume_admin" {
  provider = aws.bootstrap
  name     = "etevers-sts-assume-admin"
  user     = aws_iam_user.etevers.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowAssumeAdminRole"
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Resource = "arn:aws:iam::763940551622:role/assume-id-admin"
        # (선택) MFA 강제 — 신뢰정책 대신 여기에 조건을 걸 수도 있음.
        # Condition = {
        #   Bool = { "aws:MultiFactorAuthPresent" = "true" }
        # }
      }
    ]
  })
}
