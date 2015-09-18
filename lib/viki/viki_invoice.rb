class Viki::VikiInvoice < Viki::Core::Base
  path '/users/:user_id/invoices', api_version: 'v5'
end
