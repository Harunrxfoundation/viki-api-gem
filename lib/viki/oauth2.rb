class Viki::OAuth2 < Viki::Core::Base
  GET_CLIENT = 'get'
  AUTHENTICATE_CLIENT = 'auth'
  path '/oauth/applications/uids/:uid', api_version: "v4", name: GET_CLIENT
  path '/oauth/authorize', api_version: "v4", name: AUTHENTICATE_CLIENT

  def self.get_client(uid)
    self.fetch_sync({ named_path: GET_CLIENT, uid: uid })
  end

  def self.precheck_client(body = {})
    self.fetch_sync(body.merge(named_path: AUTHENTICATE_CLIENT))
  end

  def self.auth_client(body = {})
    self.create_sync({ named_path: AUTHENTICATE_CLIENT }, body)
  end
end
