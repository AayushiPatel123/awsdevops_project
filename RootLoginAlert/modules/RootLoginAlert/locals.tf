locals {
  common_tags = {
    Project         = "CaylentWay"
    Owner           = "Caylent"
    Created_Using   = "Terraform"
  }
  lambda_configuration = {
    handler         = "RootActivityLambda.lambda_handler"
    runtime         = "python3.8"
    timeout         = 60
    principal       = "events.amazonaws.com"
    action          = "lambda:InvokeFunction"
    statement_id    = "AllowExecutionFromCloudWatch"
  }
}