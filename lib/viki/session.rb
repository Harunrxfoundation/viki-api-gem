class Viki::Session < Viki::Core::Base
  class AuthenticationError; end

  path '/sessions', api_version: 'v5'
  path '/sessions/:token', api_version: 'v5'

  def self.authenticate(login_id, password, params = {}, &block)
    body = params.merge('username' => login_id, 'password' => password, persist: false)
    uri = signed_uri({}, body)
    Viki.logger.info "#{name} authenticating #{login_id} to the API: #{uri}"
    creator = Viki::Core::Creator.new(uri, body)
    creator.queue &block
  end

  def self.auth_facebook(token, params = {}, &block)
    body = params.merge('facebook_token' => token, persist: false)
    uri = signed_uri({}, body)
    Viki.logger.info "#{name} authenticating facebook token to the API: #{uri}"
    creator = Viki::Core::Creator.new(uri, body)
    creator.queue &block
  end

  def self.auth_rakuten_openid(rakuten_params, params = {}, &block)
    body = params.merge('rakuten_params' => rakuten_params, persist: false)
    uri = signed_uri({}, body)
    Viki.logger.info "#{name} authenticating rakuten params to the API: #{uri}"
    creator = Viki::Core::Creator.new(uri, body)
    creator.queue &block
  end

  def self.auth_google_plus(token, params = {}, &block)
    body = params.merge('google_token' => token, persist: false)
    uri = signed_uri({}, body)
    Viki.logger.info "#{name} authenticating google token to the API: #{uri}"
    creator = Viki::Core::Creator.new(uri, body)
    creator.queue &block
  end

  def self.auth_preauthenticated(user_id, app_id, params = {}, &block)
    preauth_info = {
      preauth_details: {
        user_id: user_id,
        app_id: app_id
      },
      persist: false
    }

    body = params.merge(preauth_info)
    uri = signed_uri({}, body)

    Viki.logger.info "#{name} authenticating with preauthentication to the API: #{uri}"

    creator = Viki::Core::Creator.new(uri, body)
    creator.queue &block
  end
end
