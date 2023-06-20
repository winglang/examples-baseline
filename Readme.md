# AWS Setup for Github OIDC

Enables provisioning of AWS IAM roles for use in Github Actions via [OIDC](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services).

This is using a Terraform module (https://github.com/philips-labs/terraform-aws-github-oidc) to do the setup.

## Repos

- [Examples](./repos/examples/) (`207534322588`)
- [Website](./repos/website/) (`914426143740`)

## Usage

Since this is bootstrapping the usage of Github Actions, deployments have to be done locally right now.

Get [pnpm](https://pnpm.io/installation)

```
pnpm install
pnpm run website:compile
pnpm run website:deploy
```

## Terraform State

The Terraform state should be moved somewhere else than Sebastian's computer :)