
module "root_login_alert" {

  source                = "./modules/RootLoginAlert/"
  event_name            = "RootLoginActivity"
  sns_subscription      = ["alvinmanish234@gmail.com"]
}
