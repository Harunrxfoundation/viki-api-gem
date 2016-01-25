require 'spec_helper'

describe Viki::VikiPaymentTransaction do
  describe 'fetch list of user payment transactions' do
    it '/viki_payment_transactions' do
      stub_api 'viki_payment_transactions.json', Oj.dump([{'key' => 'value'}]), {api_version: 'v5', method: 'get'}
      described_class.fetch do |response|
        res = response.value.first
        expect(res['key']).to eq 'value'
      end
    end
  end
  describe 'fetch a payment transactions' do
    it '/viki_payment_transactions' do
      stub_api 'viki_payment_transactions/1vpt.json', Oj.dump([{'key' => 'value'}]), {api_version: 'v5', method: 'get'}
      described_class.fetch(id: '1vpt') do |response|
        res = response.value.first
        expect(res['key']).to eq 'value'
      end
    end
  end
  describe 'refund a transaction' do
    it 'viki_payment_transactions/:id/refund' do
      stub_api 'viki_payment_transactions/1vpt/refund.json', Oj.dump([{'key' => 'value'}]), {api_version: 'v5', method: 'post'}
      described_class.refund(id: '1vpt') do |response|
        res = response.value.first
        expect(res['key']).to eq 'value'
      end
    end
  end
end
