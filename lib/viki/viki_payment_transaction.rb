class Viki::VikiPaymentTransaction < Viki::Core::Base
  path '/users/:user_id/payment_transactions', api_version: 'v5'
end
