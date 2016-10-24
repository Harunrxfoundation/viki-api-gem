require 'spec_helper'

describe Viki::Recommendation, api: true do
  it 'fetches recaps for a video when video_id is specified' do
    stub_api 'recommendations.json', json_fixture(:recommendations)
    described_class.fetch(engine: 'merlion', uuid: '424242') do |response|
      values = response.value
      values.should be_a_kind_of(Array)
      values.first['id'].should == '50c'
    end
  end
end
