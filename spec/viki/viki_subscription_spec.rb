require 'spec_helper'

describe Viki::VikiSubscription, api: true do
  describe 'list of subscriptions of user' do
    it 'viki_subscriptions.json' do
      stub_api 'viki_subscriptions.json', Oj.dump([{'key' => 'value'}]), {api_version: 'v5', method: 'get'}
      described_class.fetch_sync do |response|
        res = response.value.first
        expect(res['key']).to eq 'value'
      end
    end
  end
  describe 'show' do
    it 'viki_subscription/:id.json' do
      stub_api 'viki_subscriptions/1vs.json', Oj.dump([{'key' => 'value'}]), {api_version: 'v5', method: 'get'}
      described_class.fetch_sync(id: '1vs') do |response|
        res = response.value.first
        expect(res['key']).to eq 'value'
      end
    end
  end
  describe 'create' do
    it 'viki_subscriptions.json' do
      stub_api 'viki_subscriptions.json', Oj.dump([{'key' => 'value'}]), {api_version: "v5", method: 'post'}
      described_class.create_sync(user_id: '1u', plan_id: '1p') do |response|
        res = response.value.first
        expect(res['key']).to eq 'value'
      end
    end
  end
  describe 'destroy' do
    it 'viki_subscriptions/:id.json' do
      stub_api 'viki_subscriptions/1vs.json', Oj.dump([{'key' => 'value'}]), {api_version: "v5", method: 'delete'}
      described_class.destroy_sync(id: '1vs') do |response|
        res = response.value.first
        expect(res['key']).to eq 'value'
      end
    end
  end
  describe 'update' do
    it 'viki_subscriptions/:id.json' do
      stub_api 'viki_subscriptions/1vs.json', Oj.dump([{'key' => 'value'}]), {api_version: "v5", method: 'put'}
      described_class.update_sync(id: '1vs') do |response|
        res = response.value.first
        expect(res['key']).to eq 'value'
      end
    end
  end
  describe 'applied_coupons' do
    it 'viki_subscriptions/:id.json' do
      stub_api 'viki_subscriptions/1vs/applied_coupons.json', Oj.dump([{'key' => 'value'}]), {api_version: "v5", method: 'get'}
      described_class.applied_coupons(viki_subscription_id: '1vs') do |response|
        res = response.value.first
        expect(res['key']).to eq 'value'
      end
    end
  end
  describe 'gift_card' do
    it 'viki_subscriptions/:id.json' do
      stub_api 'viki_subscriptions/1vs/gift_card.json', Oj.dump([{'key' => 'value'}]), {api_version: "v5", method: 'get'}
      described_class.gift_card(viki_subscription_id: '1vs') do |response|
        res = response.value.first
        expect(res['key']).to eq 'value'
      end
    end
  end
  describe 'periods' do
    it 'viki_subscriptions/:id/periods.json' do
      stub_api 'viki_subscriptions/1vs/periods.json', Oj.dump([{'key' => 'value'}]), {api_version: "v5", method: 'get'}
      described_class.periods(viki_subscription_id: '1vs') do |response|
        res = response.value.first
        expect(res['key']).to eq 'value'
      end
    end
  end
end
