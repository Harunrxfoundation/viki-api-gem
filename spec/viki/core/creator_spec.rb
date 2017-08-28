require 'spec_helper'

describe Viki::Core::Creator do
  describe '#create' do
    let(:body) { {'title' => 'City Hunter'} }
    let(:content) { "ok" }
    let(:status) { 200 }
    let(:creator) { Viki::Core::Creator.new("http://example.com/path", content, {}) }
    let!(:req_stub) do
      stub_request("post", "http://example.com/path").
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
      Viki.should_receive(:user_ip).exactly(3) { lambda { "1.2.3.4" } }
      creator.queue do
        WebMock.should have_requested("post", "http://example.com/path").
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

    describe "cache busting" do
      let(:cache_bust_path) { '/highlander/javanese' }
      let(:cache_ns) { 'some_namespace' }
      let(:cacheable_creator) { Viki::Core::Creator.new("http://example.com/path", content, {}, 'json', { cache_seconds: 5 }, { path: cache_bust_path }) }
      let(:cache_keys) { ['/highlander/javanese/1', '/highlander/javanese/2', '/highlander/javanese/3'] }

      let(:cache) do
        {}.tap do |c|
          def c.keys(query)
          end

          def c.del(*k)
          end
        end
      end

      before do
        Viki.stub(:cache).and_return(cache)
        Viki.stub(:cache_ns).and_return(cache_ns)
      end

      describe 'does not cache bust' do
        it 'if cachebustable option is not set' do
          creator.queue do |response|
          end
          creator.should_not_receive(:cache_bust)
        end

        describe 'if route results in an error' do
          let(:content) { {"error" => "an error occurred", "vcode" => 123} }
          let(:status) { 401 }

          it do
            cacheable_creator.queue do |response|
            end
            cacheable_creator.should_not_receive(:cache_bust)
          end
        end
      end

      it 'cache bust' do
        cacheable_creator.queue do |response|
        end
        cacheable_creator.should_receive(:cache_bust).with(no_args)
      end

      it 'cache bust with constituent keys retrieval for delete' do
        cacheable_creator.queue do |response|
        end
        Viki.cache.should_receive(:keys).with("#{cache_ns}.#{cache_bust_path}*").and_return(cache_keys)
        Viki.cache.should_receive(:del).with(*cache_keys).and_return(nil)
      end

      it 'cache bust with no keys to delete' do
        cacheable_creator.queue do |response|
        end
        Viki.cache.should_receive(:keys).with("#{cache_ns}.#{cache_bust_path}*").and_return([])
        Viki.cache.should_not_receive(:del).with(*cache_keys)
      end
    end
  end
end
