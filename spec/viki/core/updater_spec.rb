require 'spec_helper'

describe Viki::Core::Updater do
  describe '#update' do
    let(:body) { {'title' => 'City Hunter'} }
    let(:content) { "ok" }
    let(:status) { 200 }
    let(:creator) { Viki::Core::Updater.new("http://example.com/path", content, {}) }
    let!(:req_stub) do
      stub_request("put", "http://example.com/path").
        with(body: Oj.dump(content, mode: :compat)).
        to_return(body: Oj.dump(content, mode: :compat), status: status)
    end

    it "runs the request" do
      creator.queue do |response|
        response.error.should be_nil
      end
      Viki.run # This also runs in a before filter, but we want to make sure the request is made
      req_stub.should have_been_made
    end

    it "sends the user IP as X-FORWARDED-FOR" do
      Viki.should_receive(:user_ip).twice { lambda { "1.2.3.4" } }
      creator.queue do
        WebMock.should have_requested("put", "http://example.com/path").
                         with(:headers => {'X-Forwarded-For' => "1.2.3.4"})
      end
    end

    context "error response" do
      let(:content) { {"error" => "an error occurred", "vcode" => 123} }
      let(:status) { 401 }

      it 'yields the error' do
        creator.queue do |response|
          error = response.error
          error.should be_a(Viki::Core::ErrorResponse)
          error.status.should == 401
          error.error.should == "an error occurred"
          error.vcode.should == 123
          error.url.should == "http://example.com/path"
        end
      end
    end

  end
end
