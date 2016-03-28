require 'spec_helper'

describe Viki::VikiInvoice do
  describe 'get list of invoices' do
    it '/viki_invoices.json' do
      stub_api 'viki_invoices.json', Oj.dump([{'key' => 'value'}]), {api_version: 'v5', method: 'get'}
      described_class.fetch do |response|
        res = response.value.first
        expect(res['key']).to eq 'value'
      end
    end
  end
  describe 'get an invoice' do
    it '/viki_invoices/1vi' do
      stub_api 'viki_invoices/1vi.json',Oj.dump([{'key' => 'value'}]), {api_version: 'v5', method: 'get'}
      described_class.fetch(id: '1vi') do |response|
        res = response.value.first
        expect(res['key']).to eq 'value'
      end
    end
  end
  describe 'update a user invoice' do
    it '/viki_invoices/1vi' do
      stub_api 'viki_invoices/1vi.json', Oj.dump([{'key' => 'value'}]), {api_version: 'v5', method: 'put'}
      described_class.update(id: '1vi') do |response|
        res = response.value.first
        expect(res['key']).to eq 'value'
      end
    end
  end
  describe 'retrieve line items' do
    it '/viki_invoices/1vi/invoice_line_items.json' do
      stub_api 'viki_invoices/1vi/invoice_line_items.json',Oj.dump([{'key' => 'value'}]), {api_version: 'v5', method: 'get'}
      described_class.invoice_line_items(viki_invoice_id: '1vi') do |response|
        res = response.value.first
        expect(res['key']).to eq 'value'
      end
    end
  end
  describe 'retrieve payment transactions' do
    it '/viki_invoices/1vi/payment_transactions.json' do
      stub_api 'viki_invoices/1vi/payment_transactions.json',Oj.dump([{'key' => 'value'}]), {api_version: 'v5', method: 'get'}
      described_class.payment_transactions(viki_invoice_id: '1vi') do |response|
        res = response.value.first
        expect(res['key']).to eq 'value'
      end
    end
  end
end
