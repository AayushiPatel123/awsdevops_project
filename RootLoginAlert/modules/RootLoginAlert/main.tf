##########################################
# SNS Topic and it's subscription
##########################################

resource "aws_sns_topic" "root_activity_sns_topic" {
  name                = "${var.event_name}-topic"
  display_name        = "Root-Login-Alert"
  kms_master_key_id = "arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:key/${aws_kms_key.sns_kms_key.id}"
  tags                = local.common_tags
}

resource "aws_sns_topic_subscription" "root_activity_sns_subscription" {
  for_each      = { for idx, endpoint in var.sns_subscription : idx => endpoint }
  topic_arn     = aws_sns_topic.root_activity_sns_topic.arn
  protocol      = "email"
  endpoint      = each.value
}

##########################################
# Lambda Function 
##########################################

resource "aws_lambda_function" "root_activity_lambda_function" {
  filename      = "RootActivityLambda.zip"
  function_name = "${var.event_name}-lambda_function"
  role          = aws_iam_role.lambda_role.arn
  handler       = local.lambda_configuration.handler
  runtime       = local.lambda_configuration.runtime
  timeout       = local.lambda_configuration.timeout
  environment {
    variables = {
      sns_arn   = aws_sns_topic.root_activity_sns_topic.arn 
    }
  }

  tags          = local.common_tags
}

##########################################
# Lambda permissions 
##########################################

resource "aws_lambda_permission" "allow_events" {
  statement_id  = local.lambda_configuration.statement_id
  action        = local.lambda_configuration.action
  principal     = local.lambda_configuration.principal
  function_name = aws_lambda_function.root_activity_lambda_function.function_name
  source_arn    = aws_cloudwatch_event_rule.root_activity_events_rule.arn
}


##########################################
# Cloudwatch Event Rule and it's Target
##########################################

resource "aws_cloudwatch_event_rule" "root_activity_events_rule" {
  name          = "${var.event_name}-EventRule"
  description   = "Event rule for monitoring root API login Activity"
  event_pattern = <<EOF
{
  "detail-type": ["AWS Console Sign In via CloudTrail"],
  "source": ["aws.signin"],
  "detail": {
    "userIdentity": {
      "type": ["Root"]
    },
    "responseElements": {
      "ConsoleLogin": ["Success"]
    },
    "eventType": ["AwsConsoleSignIn"]
  }
}
EOF
  tags          = local.common_tags
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.root_activity_events_rule.name
  arn       = aws_lambda_function.root_activity_lambda_function.arn
}

##########################################
# Cloudwatch Log Groups
##########################################

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name       = "/aws/lambda/${var.event_name}-lambda_function"
  retention_in_days = var.retention_in_days
  kms_key_id = "arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:key/${aws_kms_key.cloudwatch_kms_key.id}"

  tags = local.common_tags
}