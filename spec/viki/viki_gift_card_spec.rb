require 'spec_helper'

describe Viki::VikiGiftCard, api: true do
  describe 'fetcher' do
    it '/viki_gift_cards.json' do
      stub_api 'viki_gift_cards.json', Oj.dump([{'key' => 'value'}]), {api_version: 'v5', method: 'get'}
      described_class.fetch_sync do |response|
        res = response.value.first
        expect(res['key']).to eq 'value'
      end
    end
  end
  describe 'fetch gift card by gift code' do
    it '/viki_gift_cards/:gift_code.json' do
      stub_api 'viki_gift_cards/abcdef.json', Oj.dump({'key' => 'value'}), {api_version: 'v5', method: 'get'}
      described_class.fetch_sync(gift_code: 'abcdef') do |response|
        expect(response.value['key']).to eq 'value'
      end
    end
  end
  describe 'fetch all user gift card' do
    it '/users/:user_id/viki_gift_cards.json' do
      stub_api 'users/1u/viki_gift_cards.json', Oj.dump([{'key' => 'value'}]), {api_version: 'v5', method: 'get'}
      described_class.fetch_sync(user_id: '1u') do |response|
        res = response.value.first
        expect(res['key']).to eq 'value'
      end
    end
  end
  describe 'fetch all user gift card with gift code' do
    it '/users/:user_id/viki_gift_cards/:gift_code.json' do
      stub_api 'users/1u/viki_gift_cards/abcdef.json', Oj.dump({'key' => 'value'}), {api_version: 'v5', method: 'get'}
      described_class.fetch_sync(user_id: '1u', gift_code: 'abcdef') do |response|
        expect(response.value['key']).to eq 'value'
      end
    end
  end
  describe 'redeem' do
    it '/users/:user_id/viki_gift_cards/:gift_code/redeem.json' do
      stub_api 'users/1u/viki_gift_cards/asdfgh/redeem.json', Oj.dump([{'key' => 'value'}]), {api_version: 'v5', method: 'post'}
      described_class.redeem(user_id: '1u', gift_code: 'asdfgh') do |response|
        res = response.value.first
        expect(res['key']).to eq 'value'
      end
    end
  end
end
