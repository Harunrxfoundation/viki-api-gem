require 'spec_helper'

describe Viki::OAuth2, api: true do
  it "sends out a POST request for authorizing client and retrieving credentials" do
    stub = stub_request('post', %r{.*/oauth/authorize.*})

    described_class.auth_client({}) do
    end
    Viki.run
    stub.should have_been_made
  end
end
