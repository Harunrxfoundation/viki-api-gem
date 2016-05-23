require 'spec_helper'

describe Viki::Contributor, api: true do
  it 'fetches contributor\'s count' do
    stub_api 'contributors/1/count.json', '{}'
    described_class.fetch_count(user_id: "1") do |res|
      res.error.should be_nil
    end
  end

  it 'fetches contributor\'s meta' do
    stub_api 'contributors/1/meta.json', '{}'
    described_class.fetch_meta(user_id: '1') do |res|
      res.error.should be_nil
    end
  end

  it 'updates contributor\'s meta' do
    stub_api 'contributors/1/meta.json', '{}', method: 'put'
    described_class.update_meta(user_id: '1', latest_tutorial_step: 'welcome') do |res|
      res.error.should be_nil
    end
  end
end
