class Viki::VikiInvoice < Viki::Core::Base
  INVOICE_LINE_ITEMS = 'invoice_line_items'
  PAYMENT_TRANSACTIONS = 'payment_transactions'

  path '/viki_invoices', api_version: 'v5'
  path '/viki_invoices/:viki_invoice_id/invoice_line_items', api_version: 'v5', name: INVOICE_LINE_ITEMS
  path '/viki_invoices/:viki_invoice_id/payment_transactions', api_version: 'v5', name: PAYMENT_TRANSACTIONS

  def self.invoice_line_items(options = {})
    Viki::VikiInvoice.fetch_sync(options.merge(named_path: INVOICE_LINE_ITEMS))
  end
  def self.payment_transactions(options = {})
    Viki::VikiInvoice.fetch_sync(options.merge(named_path: PAYMENT_TRANSACTIONS))
  end
end
