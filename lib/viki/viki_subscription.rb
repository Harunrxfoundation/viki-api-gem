class Viki::VikiSubscription < Viki::Core::Base
  SUBSCRIPTION_INFO = 'subscription_info'
  path '/users/:user_id/plans/:plan_id', api_version: 'v5'
  path '/users/:user_id/subscription_info', api_version: 'v5', name: SUBSCRIPTION_INFO

  def self.subscription_info(options = {})
    self.fetch(options.merge(named_path: SUBSCRIPTION_INFO))
  end
end
