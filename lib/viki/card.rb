# Card here is credit card
class Viki::Card < Viki::Core::Base
  cacheable
  path '/users/:user_id/card'
end