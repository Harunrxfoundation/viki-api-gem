require 'spec_helper'

describe Viki::VikiInvoice do
  describe 'get list of user invoices' do
    it '/users/:user_id/invoices.json' do
      stub_api 'users/1u/invoices.json', Oj.dump([{'key' => 'value'}]), {api_version: 'v5', method: 'get'}
      described_class.fetch(user_id: '1u') do |response|
        res = response.value.first
        expect(res['key']).to eq 'value'
      end
    end
  end
end
