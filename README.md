# API Gateway Custom Authorizer with AWS Cognito for Ruby

This repository is an example for creating API Gateway Custom Authorizer with Cognito for Ruby.

## Setup

First, you need to replace the value of `COGNITO_USER_POOL_ID` with your CognitoUserPoolId in serverless.yml.

Then, run these commands.

```bash
$ npm install -g serverless
$ npm install
$ sls deploy
```

## Testing

you can test this API to use `curl` command

```bash
curl --header "Authorization: bearer <id_token>" https://{api}.execute-api.{region}.amazonaws.com/api/private
```
