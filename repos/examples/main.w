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
  variables: {
    "thumbprint_list" => [
      "6938fd4d98bab03faadb97b34396831e3780aea1",
      "1c58a3a8518e8759bf075b76b750d4f2df264fcd"
    ]
  }
) as "provider";

// ~~~ Examples Repo winglang/examples ~~~

let base = new Policy("generic-action", "policy.json");
let cfn = new Policy("cfn-action", "policy.cfn.json") as "policy-cfn";
let boundary = new Policy("boundary", "policy.boundary.json") as "policy-boundary";

let repo = new cdktf.TerraformHclModule(
  source: "philips-labs/github-oidc/aws",
  variables: {
    "openid_connect_provider_arn" => provider.get("openid_connect_provider.arn"),
    "repo" => "winglang/examples",
    "role_name" => "wing-examples",
    "default_conditions" => ["allow_main"],
    "role_policy_arns" => [base.policy.arn, cfn.policy.arn],
    "conditions" => [{
      "test" => "StringLike",
      "variable" => "token.actions.githubusercontent.com:sub",
      "values" => cdktf.Token.asString(["repo:winglang/examples:pull_request"])
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


// ~~~ Github Action Repo winglang/wing-github-action ~~~


let githubActionPolicy = new Policy("github-action-policy", "github-action-policy.json") as "github-action-policy";
let githubActionRepo = new cdktf.TerraformHclModule(
  source: "philips-labs/github-oidc/aws",
  variables: {
    "openid_connect_provider_arn" => provider.get("openid_connect_provider.arn"),
    "repo" => "winglang/wing-github-action",
    "role_name" => "wing-github-action",
    "default_conditions" => ["allow_main"],
    "role_policy_arns" => [githubActionPolicy.policy.arn],
    "conditions" => [{
      "test" => "StringLike",
      "variable" => "token.actions.githubusercontent.com:sub",
      "values" => cdktf.Token.asString(["repo:winglang/wing-github-action:pull_request"])
    }]
  }
) as "wing-github-action";

// get the role arn for the github action
new cdktf.TerraformOutput(
  value: githubActionRepo.get("role.arn")
) as "github-action-role-arn";


// ~~~ Static Website winglang/example-static-website ~~~

let staticWebsite = new cdktf.TerraformHclModule(
  source: "philips-labs/github-oidc/aws",
  variables: {
    "openid_connect_provider_arn" => provider.get("openid_connect_provider.arn"),
    "repo" => "winglang/example-static-website",
    "role_name" => "example-static-website",
    "default_conditions" => ["allow_main"],
    "role_policy_arns" => [base.policy.arn, cfn.policy.arn],
    "conditions" => [{
      "test" => "StringLike",
      "variable" => "token.actions.githubusercontent.com:sub",
      "values" => cdktf.Token.asString(["repo:winglang/example-static-website:pull_request"])
    }]
  }
) as "static-website-repo";

// get the role arn for the github action
new cdktf.TerraformOutput(
  value: staticWebsite.get("role.arn")
) as "static-website-role-arn";
