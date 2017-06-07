require 'spec_helper'

describe Viki::PurchasablePlans, api: true do
  it "gets all the purchasable_plans of the current user" do
    stub = stub_request('get', %r{.*/purchasable_plans.json.*})

    described_class.fetch({ features: "noads,hd", verticals: "1pv" }) do
    end
    Viki.run
    stub.should have_been_made
  end
end
