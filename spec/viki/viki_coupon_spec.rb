require 'spec_helper'

describe Viki::VikiCoupon do
  describe 'fetch list of coupons' do
    it '/viki_coupons' do
      stub_api 'viki_coupons.json', Oj.dump([{'key' => 'value'}]), {api_version: 'v5', method: 'get'}
      described_class.fetch do |response|
        res = response.value.first
        expect(res['key']).to eq 'value'
      end
    end
  end
  describe 'fetch a coupon' do
    it 'viki_coupons/:id' do
      stub_api 'viki_coupons/1vc.json', Oj.dump([{'key' => 'value'}]), {api_version: 'v5', method: 'get'}
      described_class.fetch(id: '1vc') do |response|
        res = response.value.first
        expect(res['key']).to eq 'value'
      end
    end
  end
  describe 'create a gift card type' do
    it 'viki_coupons/:id' do
      stub_api 'viki_coupons/1vc.json', Oj.dump([{'key' => 'value'}]), {api_version: 'v5', method: 'post'}
      described_class.create(id: '1vc') do |response|
        res = response.value.first
        expect(res['key']).to eq 'value'
      end
    end
  end
  describe 'update a gift card type' do
    it 'viki_coupons/:id' do
      stub_api 'viki_coupons/1vc.json', Oj.dump([{'key' => 'value'}]), {api_version: 'v5', method: 'patch'}
      described_class.patch(id: '1vc') do |response|
        res = response.value.first
        expect(res['key']).to eq 'value'
      end
    end
  end
  describe 'destroy a gift card type' do
    it 'viki_coupons/:id' do
      stub_api 'viki_coupons/1vc.json', Oj.dump([{'key' => 'value'}]), {api_version: 'v5', method: 'delete'}
      described_class.destroy(id: '1vc') do |response|
        res = response.value.first
        expect(res['key']).to eq 'value'
      end
    end
  end
  describe 'list of applied coupons' do
    it 'viki_coupons/:id/applied_coupons' do
      stub_api 'viki_coupons/1vc/applied_coupons.json', Oj.dump([{'key' => 'value'}]), {api_version: 'v5', method: 'get'}
      described_class.applied_coupons(viki_coupon_id: '1vc') do |response|
        res = response.value.first
        expect(res['key']).to eq 'value'
      end
    end
  end
end
