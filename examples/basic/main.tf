provider "aws" {
  region = "eu-west-1"
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "task_execution_role" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]
    resources = ["*"]
  }
}

module "vpc" {
  source  = "schubergphilis/mcaf-vpc/aws"
  version = "~> 1.22.0"

  name                = "redshift-vpc"
  availability_zones  = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  cidr_block          = "10.10.0.0/16"
  private_subnet_bits = 24
  public_subnet_bits  = 24
  tags                = { Environment = "test", Stack = "Example" }
}

module "pets" {
  source                   = "../.."
  name                     = "fargate"
  image                    = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/pets:latest"
  ecs_subnet_ids           = module.vpc.private_subnet_ids
  load_balancer_subnet_ids = module.vpc.public_subnet_ids
  protocol                 = "HTTP"
  role_policy              = data.aws_iam_policy_document.task_execution_role.json
  vpc_id                   = module.vpc.id
}
