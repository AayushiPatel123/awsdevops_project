
module "root_login_alert" {

  source                = "./modules/RootLoginAlert/"
  event_name            = "RootLoginActivity"
  sns_subscription      = ["aayushipatel0997@gmail.com"]
}
