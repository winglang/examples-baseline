bring cloud;
bring "cdktf" as cdktf;
bring "@cdktf/provider-aws" as aws;

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
let cfn = new Policy("cfn-action", "policy.cfn.json") as "policy-cfn";
let boundary = new Policy("boundary", "policy.boundary.json") as "policy-boundary";

// the actual repo role definition via the module

let repo = new cdktf.TerraformHclModule(
  source: "philips-labs/github-oidc/aws",
  variables: {
    openid_connect_provider_arn: provider.get("openid_connect_provider.arn"),
    repo: "winglang/examples",
    role_name: "wing-examples",
    default_conditions: ["allow_main"],
    role_policy_arns: [base.policy.arn, cfn.policy.arn],
    conditions: [{
      test: "StringLike",
      variable: "token.actions.githubusercontent.com:sub",
      values: cdktf.Token.asString(["repo:winglang/examples:pull_request"])
    }]
  }
) as "examples-repo";

// get the role arn for the github action
new cdktf.TerraformOutput(
  value: repo.get("role.arn")
) as "examples-role-arn";

// not used right now, potentially for future use in a wing plugin
new cdktf.TerraformOutput(
  value: boundary.policy.arn
) as "policy-boundary-arn";

// needed for cdk bootstrap
new cdktf.TerraformOutput(
  value: base.policy.arn
) as "policy-base-arn";