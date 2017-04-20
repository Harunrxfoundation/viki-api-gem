class Viki::OAuth2 < Viki::Core::Base
  AUTHENTICATE_CLIENT = 'auth'
  path '/oauth/authorize', api_version: "v4", name: AUTHENTICATE_CLIENT

  def self.auth_client(body = {}, &block)
    self.create({ named_path: AUTHENTICATE_CLIENT }, body, &block)
  end
end
