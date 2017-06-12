class Viki::VikiSubscriptionStatus < Viki::Core::Base
  cacheable
  path "/users/:user_id/viki_subscription_status", api_version: 'v5'
end
