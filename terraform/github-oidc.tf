resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  tags = {
    Name = "${local.name_prefix}-github-oidc"
  }
}

data "aws_iam_policy_document" "github_actions_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type = "Federated"

      identifiers = [
        aws_iam_openid_connect_provider.github.arn
      ]
    }

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"

      values = [
        "sts.amazonaws.com"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"

      values = [
        "repo:${var.github_repository_owner}@${var.github_repository_owner_id}/${var.github_repository_name}@${var.github_repository_id}:ref:refs/heads/${var.github_deployment_branch}"
      ]
    }
  }
}

resource "aws_iam_role" "github_actions_backend" {
  name = "${local.name_prefix}-github-actions-backend-role"

  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json

  tags = {
    Name = "${local.name_prefix}-github-actions-backend-role"
  }
}

data "aws_iam_policy_document" "github_actions_backend_permissions" {
  statement {
    sid    = "GetECRAuthorizationToken"
    effect = "Allow"

    actions = [
      "ecr:GetAuthorizationToken"
    ]

    resources = [
      "*"
    ]
  }

  statement {
    sid    = "PushBackendImages"
    effect = "Allow"

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart"
    ]

    resources = [
      aws_ecr_repository.backend.arn
    ]
  }

  statement {
    sid    = "ReadCurrentTaskDefinition"
    effect = "Allow"

    actions = [
      "ecs:DescribeTaskDefinition"
    ]

    resources = [
      "*"
    ]
  }

  statement {
    sid    = "RegisterTaskDefinition"
    effect = "Allow"

    actions = [
      "ecs:RegisterTaskDefinition"
    ]

    resources = [
      "*"
    ]
  }

  statement {
    sid    = "DeployBackendService"
    effect = "Allow"

    actions = [
      "ecs:DescribeServices",
      "ecs:UpdateService"
    ]

    resources = [
      aws_ecs_service.backend.id
    ]
  }

  statement {
    sid    = "PassECSTaskRoles"
    effect = "Allow"

    actions = [
      "iam:PassRole"
    ]

    resources = [
      aws_iam_role.ecs_task_execution.arn,
      aws_iam_role.ecs_task.arn
    ]

    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"

      values = [
        "ecs-tasks.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role_policy" "github_actions_backend" {
  name = "${local.name_prefix}-github-actions-backend-policy"
  role = aws_iam_role.github_actions_backend.id

  policy = data.aws_iam_policy_document.github_actions_backend_permissions.json
}