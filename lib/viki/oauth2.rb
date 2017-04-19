class Viki::OAuth2 < Viki::Core::Base
  AUTHENTICATE_CLIENT = 'auth'
  LOGIN = 'login'
  path '/oauth/authorize', api_version: "v4", name: AUTHENTICATE_CLIENT
  path '/oauth/token', api_version: "v4", name: LOGIN

  def self.auth_client(options = {}, &block)
    self.fetch(options.merge(named_path: AUTHENTICATE_CLIENT), &block)
  end

  def self.login(options = {}, body = {}, &block)
    self.create(options.merge(named_path: LOGIN), body, &block)
  end
end
