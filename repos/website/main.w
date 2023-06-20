bring cloud;
bring "cdktf" as cdktf;
bring "@cdktf/provider-aws" as aws;

let repoName = "winglang/website-proxy";
// in liue of a better way to normalize the name, e.g. str.replace(/[^a-zA-Z0-9]/g, "-")
// https://github.com/winglang/wing/issues/2988
let repoNameNormalized = "winglang-website-proxy";

class Policy {
  name: str;
  policy: aws.iamPolicy.IamPolicy;

  init(name: str, file: str) {
    this.name = name;

    let policyAsset = new cdktf.TerraformAsset(
      path: file
    );

    this.policy = new aws.iamPolicy.IamPolicy(
      namePrefix: this.name,
      policy: cdktf.Fn.file(policyAsset.path)
    );
  }
}

// needs to be present once in the account
let provider = new cdktf.TerraformHclModule(
  source: "philips-labs/github-oidc/aws//modules/provider",
) as "provider";

let base = new Policy("generic-action", "policy.json");

let repo = new cdktf.TerraformHclModule(
  source: "philips-labs/github-oidc/aws",
  variables: {
    openid_connect_provider_arn: provider.get("openid_connect_provider.arn"),
    repo: repoName,
    role_name: repoNameNormalized,
    default_conditions: ["allow_main"],
    role_policy_arns: [base.policy.arn],
    conditions: [{
      test: "StringLike",
      variable: "token.actions.githubusercontent.com:sub",
      values: cdktf.Token.asString(["repo:${repoName}:pull_request"])
    }]
  }
);

new cdktf.TerraformOutput(
  value: repo.get("role.arn")
) as "role-arn";
