class Viki::PlanSubscriber < Viki::Core::Base
  cacheable
  path "/users/:user_id/plans"
  path "/users/:user_id/plans/:plan_id"
end
