require 'spec_helper'

describe Viki::VikiPlan, api:true do
  it "fetches payment plans" do
    stub_api 'viki_plans.json', Oj.dump({ 'id' => '1p', 'name' => 'Plan1' }), api_version: 'v5'
    described_class.fetch() do |response|
      response.value['id'].should eq '1p'
      response.value['name'].should eq 'Plan1'
    end
  end
end
