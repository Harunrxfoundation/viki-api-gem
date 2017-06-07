require 'spec_helper'

describe Viki::SubscriptionTracks, api: true do
  it "gets all the subscription tracks of the current user" do
    stub = stub_request('get', %r{.*/subscription_tracks.json.*})

    described_class.fetch({}) do
    end
    Viki.run
    stub.should have_been_made
  end
end
