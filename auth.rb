# frozen_string_literal: true

require 'jwt'
require 'open-uri'

ISS = "https://cognito-idp.#{ENV['COGNITO_USER_POOL_ID'].gsub(/(?<=\d)(.*)/, '')}.amazonaws.com/#{ENV['COGNITO_USER_POOL_ID']}"

def authorize(event:, context:)
  puts 'Auth function invoked'

  token = event['authorizationToken'][7..-1]
  header = Base64.urlsafe_decode64(token.split('.')[0])
  kid = JSON.parse(header, symbolize_names: true)[:kid]

  res = OpenURI.open_uri("#{ISS}/.well-known/jwks.json")
  keys = JSON.parse(res.read, symbolize_names: true)[:keys]

  key = keys.find { |k| k[:kid] == kid }
  pem = JWT::JWK.import(key).public_key

  begin
    decoded = JWT.decode token, pem, true, verify_iat: true, iss: ISS, verify_iss: true, algorithm: 'RS256'
  rescue JWT::JWKError => e
    puts "Provided JWKs is invalid: #{e}"
    return generate_policy(nil, 'Deny', event['methodArn'])
  rescue JWT::DecodeError => e
    puts "Failed to authorize: #{e}"
    return generate_policy(nil, 'Deny', event['methodArn'])
  end

  generate_policy(decoded[0]['sub'], 'Allow', event['methodArn'])
end

def generate_policy(principal_id, effect, resource)
  auth_response = { principalId: principal_id }
  auth_response[:policyDocument] = {
    Version: '2012-10-17',
    Statement: [
      { Action: 'execute-api:Invoke', Effect: effect, Resource: resource }
    ]
  }
  auth_response
end
