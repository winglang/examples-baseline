# AWS Setup for Github OIDC

Enables provisioning of AWS IAM roles for use in Github Actions via [OIDC](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services).

This is using a Terraform module (https://github.com/philips-labs/terraform-aws-github-oidc) to do the setup.

## Usage

Since this is bootstrapping the usage of Github Actions, deployments have to be done locally right now.

```
npm install
wing compile -t tf-aws main.w
cd ./target/main.tfaws
terraform init
terraform apply
```

## Terraform State

The Terraform state should be moved somewhere else than Sebastian's computer :)