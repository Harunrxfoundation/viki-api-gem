require "spec_helper"

describe Viki::Role, api: true do
  it "fetches roles" do
    stub_api 'roles.json', json_fixture(:roles)
    described_class.fetch(user_id: "123u") do |response|
      response.value.should be_a_kind_of(Array)
    end
  end
end
