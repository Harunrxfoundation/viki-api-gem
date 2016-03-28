require 'spec_helper'

describe Viki::UserAccount do
  describe 'get user account' do
    it '/users/:user_id/account' do
      stub_api 'users/1u/account.json', Oj.dump([{'key' => 'value'}]), {api_version: 'v5', method: 'get'}
      described_class.fetch(user_id: '1u') do |response|
        res = response.value.first
        expect(res['key']).to eq 'value'
      end
    end
  end
  describe 'default card' do
    it '/users/:user_id/account/default_card' do
      stub_api 'users/1u/account/default_card.json', Oj.dump([{'key' => 'value'}]), {api_version: 'v5', method: 'get'}
      described_class.default_card(user_id: '1u') do |response|
        res = response.value.first
        expect(res['key']).to eq 'value'
      end
    end
  end
  describe 'update card' do
    it '/users/:user_id/account/update_card' do
      stub_api 'users/1u/account/update_card.json', Oj.dump([{'key' => 'value'}]), {api_version: 'v5', method: 'put'}
      described_class.update_card(user_id: '1u') do |response|
        res = response.value.first
        expect(res['key']).to eq 'value'
      end
    end
  end
end
