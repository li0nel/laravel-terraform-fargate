resource "aws_ecr_repository" "laravel" {
  name = join("-", [var.stack_name, "laravel"])
}

resource "aws_ecr_repository" "nginx" {
  name = join("-", [var.stack_name, "nginx"])
}

resource "aws_ecr_repository_policy" "policy_laravel" {
  repository = aws_ecr_repository.laravel.name
  policy     = data.aws_iam_policy_document.policy.json
}

resource "aws_ecr_repository_policy" "policy_nginx" {
  repository = aws_ecr_repository.nginx.name
  policy     = data.aws_iam_policy_document.policy.json
}

data "aws_iam_policy_document" "policy" {
  statement {
    sid = "AllowFargate"

    principals {
      type = "AWS"
      identifiers = [
        "*"
      ]
    }

    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeRepositories",
      "ecr:GetRepositoryPolicy",
      "ecr:ListImages",
      "ecr:DescribeImages",
      "ecr:DeleteRepository",
      "ecr:BatchDeleteImage",
      "ecr:SetRepositoryPolicy",
      "ecr:DeleteRepositoryPolicy",
      "ecr:GetLifecyclePolicy",
      "ecr:PutLifecyclePolicy",
      "ecr:DeleteLifecyclePolicy",
      "ecr:GetLifecyclePolicyPreview",
      "ecr:StartLifecyclePolicyPreview",
    ]
  }

  statement {
    sid = "AllowCIPipeline"

    principals {
      type = "AWS"
      identifiers = [
        var.ci_pipeline_user_arn
      ]
    }

    actions = [
      "ecr:*"
    ]
  }
}
