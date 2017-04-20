class Viki::OAuth2 < Viki::Core::Base
  AUTHENTICATE_CLIENT = 'auth'
  path '/oauth/authorize', api_version: "v4", name: AUTHENTICATE_CLIENT

  def self.auth_client(body = {}, &block)
    permitted_body = body.permit(:client_id, :response_type, :redirect_uri, :scope, :state)
    self.({ named_path: AUTHENTICATE_CLIENT }, permitted_body, &block)
  end
end
