#
# zerone-id administrator
#
resource "aws_iam_role" "assume_id_admin" {
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
        # "arn:aws:iam::${var.account_id.id}:root", # 원본
        # 소스(Assumer) 계정: 661077619249 전체 신뢰 (수정)
        "arn:aws:iam::661077619249:root",

        # (유지) 타깃(자기) 계정: 763940551622도 신뢰 유지 (수정)
        "arn:aws:iam::763940551622:root",
      ]
    }
  }
}

resource "aws_iam_role_policy" "assume_id_admin_passrole" {
  name = "assume-id-admin-passrole"
  role = aws_iam_role.assume_id_admin.id

  policy = data.aws_iam_policy_document.assume_id_admin_pass_role.json
}

data "aws_iam_policy_document" "assume_id_admin_pass_role" {
  statement {
    actions = ["iam:PassRole"]
    effect  = "Allow"

    resources = ["*"]
  }
}

resource "aws_iam_role_policy_attachment" "assume_id_admin" {
  role       = aws_iam_role.assume_id_admin.id
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}


