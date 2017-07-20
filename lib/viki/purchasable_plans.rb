class Viki::PurchasablePlans < Viki::Core::Base
  cacheable
  path "/purchasable_plans", api_version: "v5"
end
