require 'spec_helper'

describe Viki::OAuth2, api: true do
  it "sends out a POST request for authorizing client and retrieving credentials" do
    stub = stub_request('post', %r{.*/oauth/authorize.*})

    described_class.auth_client({}) do
    end
    stub.should have_been_made
  end

  it "sends out a GET request for authorizing client and retrieving credentials" do
    stub = stub_request('get', %r{.*/oauth/authorize.*})

    described_class.precheck_client({}) do
    end
    stub.should have_been_made
  end

  it "sends out a GET request for verifying client" do
    stub = stub_request('get', %r{.*/oauth/applications/uids/123.*})

    described_class.get_client('123') do
    end
    stub.should have_been_made
  end
end
