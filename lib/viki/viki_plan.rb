class Viki::VikiPlan < Viki::Core::Base
  path '/viki_plans/:plan_id', api_version: 'v5'
  path '/viki_plans', api_version: 'v5'
end
