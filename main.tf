resource "aws_codecommit_repository" "my-app" {
  repository_name = "wildrydes-site"
  description     = "https://aws.amazon.com/getting-started/hands-on/build-serverless-web-app-lambda-apigateway-s3-dynamodb-cognito/module-1/"
}

#Policy document specifying what service can assume the role
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["amplify.amazonaws.com"]
    }
  }
}
#IAM role providing read-only access to CodeCommit
resource "aws_iam_role" "amplify-codecommit" {
  name                = "AmplifyCodeCommit"
  assume_role_policy  = join("", data.aws_iam_policy_document.assume_role.*.json)
  managed_policy_arns = ["arn:aws:iam::aws:policy/AWSCodeCommitReadOnly"]
}

resource "aws_amplify_app" "wildrydes-site" {
  name       = "wildrydes-site"
  repository = aws_codecommit_repository.my-app.clone_url_http
  iam_service_role_arn = aws_iam_role.amplify-codecommit.arn
  enable_branch_auto_build = true
  build_spec = <<-EOT
    version: 1
    frontend:
      phases:
        # IMPORTANT - Please verify your build commands
        build:
          commands: []
      artifacts:
        # IMPORTANT - Please verify your build output directory
        baseDirectory: /
        files:
          - '**/*'
      cache:
        paths: []
  EOT
  # The default rewrites and redirects added by the Amplify Console.
  custom_rule {
    source = "/<*>"
    status = "404"
    target = "/index.html"
  }
  environment_variables = {
    ENV = "dev"
  }
}

resource "aws_amplify_branch" "develop" {
  app_id      = aws_amplify_app.wildrydes-site.id
  branch_name = "develop"
  framework = "React"
  stage     = "DEVELOPMENT"
}

resource "aws_amplify_branch" "master" {
  app_id      = aws_amplify_app.wildrydes-site.id
  branch_name = "master"
  framework = "React"
  stage     = "PRODUCTION"
}
