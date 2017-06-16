class Viki::VikiSubscriptionHistory < Viki::Core::Base
  cacheable
  path "/users/:user_id/viki_subscription_history", api_version: 'v5'
end
