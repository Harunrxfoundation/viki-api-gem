require 'spec_helper'

describe Viki::VikiPaymentTransaction do
  describe 'fetch list of user payment transactions' do
    it '/users/:user_id/payment_transactions' do
      stub_api 'users/1u/payment_transactions.json', Oj.dump([{'key' => 'value'}]), {api_version: 'v5', method: 'get'}
      described_class.fetch(user_id: '1u') do |response|
        res = response.value.first
        expect(res['key']).to eq 'value'
      end
    end
  end
end
