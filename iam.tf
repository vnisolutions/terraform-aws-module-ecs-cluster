/**
 * IAM
 */
data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "${var.env}-${var.project_name}-execution-task-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json

  tags = {
    Name        = "${var.env}-${var.project_name}-role"
    Environment = "${var.env}"
    Management  = "terraform"
  }
}

resource "aws_iam_role_policy" "ecsTaskExecutionPolicy" {
  name = "${var.env}-${var.project_name}-execution-task-policy"
  role = aws_iam_role.ecsTaskExecutionRole.name

  policy = <<DOC
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "ssmmessages:CreateDataChannel",
                "ssmmessages:OpenDataChannel",
                "ssmmessages:OpenControlChannel",
                "ssmmessages:CreateControlChannel",
                "ssm:GetParameters"
            ],
            "Resource": "*"
        }
    ]
}
DOC
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}
