require 'spec_helper'

describe Viki::ChannelManagerApplications, api: true do
  it "gets all the data and metadata of channel manager submissions" do
    stub = stub_request('get', %r{.*/cm_submissions.json.*})

    described_class.get({ container_id: "42c", user_id: "30u" }) do
    end
    Viki.run
    stub.should have_been_made
  end

  it "gets all the data and metadata of pending channel manager submissions" do
    stub = stub_request('get', %r{.*/cm_submissions.json.*})

    described_class.get({ container_id: "42c", status: "pending" }) do
    end
    Viki.run
    stub.should have_been_made
  end

  it "post a channel manager submission" do
    stub = stub_request('post', %r{.*/cm_submissions.json.*}).with(body: Oj.dump({"cm_submission" => {"container_id" => "42v", "user_id" => "30u"}}))
    described_class.post({}, {"cm_submission" => {"container_id" => "42v", "user_id" => "30u"}}) do
    end
    Viki.run
    stub.should have_been_made
  end
end
