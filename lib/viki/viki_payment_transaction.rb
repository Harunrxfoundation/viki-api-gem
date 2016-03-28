class Viki::VikiPaymentTransaction < Viki::Core::Base
  REFUND = 'refund'

  path '/viki_payment_transactions', api_version: 'v5'
  path '/viki_payment_transactions/:id/refund', api_version: 'v5', name: REFUND

  def self.refund(options={})
    self.create_sync(options.merge(named_path: REFUND), {})
  end
end
