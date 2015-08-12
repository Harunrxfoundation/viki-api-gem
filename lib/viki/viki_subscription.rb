class Viki::VikiSubscription < Viki::Core::Base
  path '/users/:user_id/plans/:plan_id', api_version: 'v5'
end
