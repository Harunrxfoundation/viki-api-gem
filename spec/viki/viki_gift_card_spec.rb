require 'spec_helper'

describe Viki::VikiGiftCard, api: true do
  describe 'purchase' do
    it '/users/:user_id/gift_cards/purchase.json' do
      stub_api 'users/1u/gift_cards/purchase.json', Oj.dump([{'key' => 'value'}]), {api_version: 'v5', method: 'post'}
      described_class.purchase(user_id: '1u') do |response|
        res = response.value.first
        expect(res['key']).to eq 'value'
      end
    end
  end
  describe 'redeem' do
    it '/users/:user_id/gift_cards/:gift_code/redeem.json' do
      stub_api 'users/1u/gift_cards/asdfgh/redeem.json', Oj.dump([{'key' => 'value'}]), {api_version: 'v5', method: 'post'}
      described_class.redeem(user_id: '1u', gift_code: 'asdfgh') do |response|
        res = response.value.first
        expect(res['key']).to eq 'value'
      end
    end
  end
end
