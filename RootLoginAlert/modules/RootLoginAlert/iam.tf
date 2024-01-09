resource "aws_iam_role" "lambda_role" {
  name = "${var.event_name}-LambdaRole"
  assume_role_policy = jsonencode({
    Version="2012-10-17",
    Statement=[{
        Effect= "Allow",
        Principal={
            Service=["lambda.amazonaws.com"]
        },
        Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "lambda_policy" {
  name = "${var.event_name}-LambdaPolicy"
  description = "Policy for Lambda to monitor root API Activity"
  path = "/"
  policy = jsonencode({
    Version:"2012-10-17",
    Statement:[
        {
            Sid = "LogStreamAccess",
            Effect = "Allow",
            Action = [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
            ],
            Resource = ["arn:aws:logs:*"]
        },
        {
            Sid ="SNSPublishAllow",
            Effect = "Allow",
            Action = ["sns:Publish"],
            Resource = "*",
        },
        {
            Sid ="ListAccountAlias",
            Effect = "Allow",
            Action = ["iam:ListAccountAliases"],
            Resource = "*",
        },
        {
            Sid ="AllowKMSEncryption",
            Effect = "Allow",
            Action = [
                "kms:Encrypt",
                "kms:Decrypt",
                "kms:ReEncrypt*",
                "kms:GenerateDataKey*"
            ],
            Resource = "*",
        },
    ],
  })
}

resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
  role        = aws_iam_role.lambda_role.name	
  policy_arn  = aws_iam_policy.lambda_policy.arn	
}