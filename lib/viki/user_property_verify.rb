class Viki::UserPropertyVerify < Viki::Core::Base

  VERIFY = 'verify'
  path "/users/:user_id/verify", name: VERIFY

  def self.resend_token(user_id, body = {}, &block)
    self.create({user_id: user_id}.merge(named_path: VERIFY), body, &block)
  end

  def self.verify_token(user_id, body = {}, &block)
    self.update({user_id: user_id}.merge(named_path: VERIFY), body, &block)
  end
end
