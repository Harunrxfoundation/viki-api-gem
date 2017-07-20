require 'spec_helper'

describe Viki::VikiSubscriptionHistory, api: true do
  it "gets the subscription history of the current user" do
    stub = stub_request('get', %r{.*/users/171u/viki_subscription_history.json.*})

    described_class.fetch({ user_id: '171u' }) do
    end
    Viki.run
    stub.should have_been_made
  end
end
