provider "aws" {
  region = var.region
}

module "examples" {
  source            = "./modules/examples"
}
