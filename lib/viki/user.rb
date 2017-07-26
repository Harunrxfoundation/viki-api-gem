class Viki::User < Viki::Core::Base
  use_ssl
  cacheable
  path "/users"
  path '/users/:user_id/login_history', api_version: "v4"

  def self.login_history(options = {})
    self.fetch_sync(options)
  end
end
