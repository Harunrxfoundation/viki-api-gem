require "spec_helper"

describe Viki::Holdback, api: true do
  it "fetches holdbacks" do
    stub_api 'holdbacks.json', '{"data": "some_data"}', manage: true
    data = nil
    described_class.fetch(group_ids: "1", user_ids: "1u", resource_id: "1r", manage: true) do |response|
      data = response.value
    end
    Viki.run
    data.should == {"data" => "some_data"}
  end

  it "only works for manage domain" do
    stub_api 'holdbacks.json', "some_data"
    expect {
      described_class.fetch(group_ids: "1", user_ids: "1u", resource_id: "1r")
    }.to raise_error(Viki::Core::Base::InsufficientOptions)
  end
end
