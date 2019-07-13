# frozen_string_literal: true

def public_endpoint(event:, context:)
  { statusCode: 200, body: 'Welcome to our Public API' }
end

def private_endpoint(event:, context:)
  { statusCode: 200, body: 'Only logged in users can see this' }
end
