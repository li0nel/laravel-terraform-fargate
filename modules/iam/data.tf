data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "policy" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "Service"
      identifiers = [
        "ec2.amazonaws.com",
        "ecs-tasks.amazonaws.com"
      ]
    }
  }
}

data "aws_iam_policy_document" "ci_pipeline" {
  statement {
    sid       = "AllowECRPush"
    resources = ["*"]
    actions = [
      "ecr:*"
    ]
  }

  statement {
    sid       = "AllowECSDeploy"
    resources = ["*"]
    actions = [
      "ecs:DescribeTaskDefinition",
      "ecs:RegisterTaskDefinition",
      "ecs:UpdateService"
    ]
  }

  statement {
    sid       = "IAMPassRole"
    resources = [aws_iam_role.role.arn]
    actions = [
      "iam:PassRole"
    ]
  }
}