require 'spec_helper'

describe Viki::VikiSubscriptionStatus, api: true do
  it "gets the subscription tracks of the current user" do
    stub = stub_request('get', %r{.*/users/10u/viki_subscription_status.json.*})

    described_class.fetch({ user_id: '10u' }) do
    end
    Viki.run
    stub.should have_been_made
  end
end
