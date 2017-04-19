require 'spec_helper'

describe Viki::OAuth2, api: true do
  it "sends out a GET request for authorize" do
    stub = stub_request('get', %r{.*/oauth/authorize.*})

    described_class.auth_client({}) do
    end
    Viki.run
    stub.should have_been_made
  end

  it "sends out a POST request for token retrieval" do
    stub = stub_request('post', %r{.*/oauth/token.*})

    described_class.login({}) do
    end
    Viki.run
    stub.should have_been_made
  end
end
