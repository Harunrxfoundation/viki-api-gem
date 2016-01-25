require 'spec_helper'

describe Viki::VikiGiftCardType do
  describe 'fetch list of gift card types' do
    it '/viki_gift_card_types' do
      stub_api 'viki_gift_card_types.json', Oj.dump([{'key' => 'value'}]), {api_version: 'v5', method: 'get'}
      described_class.fetch do |response|
        res = response.value.first
        expect(res['key']).to eq 'value'
      end
    end
  end
  describe 'fetch a gift card type' do
    it 'viki_gift_card_types/:id' do
      stub_api 'viki_gift_card_types/1gct.json', Oj.dump([{'key' => 'value'}]), {api_version: 'v5', method: 'get'}
      described_class.fetch(id: '1gct') do |response|
        res = response.value.first
        expect(res['key']).to eq 'value'
      end
    end
  end
  describe 'create a gift card type' do
    it 'viki_gift_card_types/:id' do
      stub_api 'viki_gift_card_types/1gct.json', Oj.dump([{'key' => 'value'}]), {api_version: 'v5', method: 'post'}
      described_class.create(id: '1gct') do |response|
        res = response.value.first
        expect(res['key']).to eq 'value'
      end
    end
  end
  describe 'update a gift card type' do
    it 'viki_gift_card_types/:id' do
      stub_api 'viki_gift_card_types/1gct.json', Oj.dump([{'key' => 'value'}]), {api_version: 'v5', method: 'patch'}
      described_class.patch(id: '1gct') do |response|
        res = response.value.first
        expect(res['key']).to eq 'value'
      end
    end
  end
  describe 'destroy a gift card type' do
    it 'viki_gift_card_types/:id' do
      stub_api 'viki_gift_card_types/1gct.json', Oj.dump([{'key' => 'value'}]), {api_version: 'v5', method: 'delete'}
      described_class.destroy(id: '1gct') do |response|
        res = response.value.first
        expect(res['key']).to eq 'value'
      end
    end
  end
end
