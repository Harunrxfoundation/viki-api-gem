require 'spec_helper'

describe Viki::Core::Fetcher do
  describe '#fetch' do
    let(:content) { {'title' => 'City Hunter'} }
    let(:status) { 200 }
    let(:fetcher) { Viki::Core::Fetcher.new("http://example.com/path", nil, {}) }

    before do
      stub_request("get", "http://example.com/path").to_return(body: Oj.dump(content, mode: :compat),
                                                               status: status)
    end

    it "returns the results of the call to the API" do
      fetcher.queue do |response|
        response.value['title'].should == 'City Hunter'
      end
    end

    it "sends the user IP as X-FORWARDED-FOR" do
      Viki.stub(:user_ip) { lambda { "1.2.3.4" } }
      fetcher.queue do
        WebMock.should have_requested("get", "http://example.com/path").
                         with(:headers => {'X-Forwarded-For' => "1.2.3.4"})
      end
    end

    context "error response" do
      let(:content) { {"error" => "an error occurred", "vcode" => 123} }
      let(:status) { 401 }

      it 'yields the error' do
        fetcher.queue do |response|
          response.value.should be_nil
          error = response.error
          error.should be_a(Viki::Core::ErrorResponse)
          error.status.should == 401
          error.error.should == "an error occurred"
          error.vcode.should == 123
          error.url.should == "http://example.com/path"
        end
      end
    end

    context "from list responses" do
      let(:content) { {
        'more' => true,
        'response' => [
        ],
        'details' => {'titles' => {'en' => 'english title'}}}
      }

      it 'loads the pagination field' do
        fetcher.queue {}
        Viki.run
        fetcher.more.should be_true
        fetcher.count.should be_nil
      end

      it 'allows access to the details attribute' do
        fetcher.queue {}
        Viki.run
        fetcher.more.should === true
        fetcher.details.should == {'titles' => {'en' => 'english title'}}
      end

      context "with_paging" do
        let(:content) { {
          'count' => 10,
          'pagination' => {
            'previous' => nil,
            'next' => "http://example.com/page2"
          },
          'response' => [
            {'title' => 'City Hunter'},
            {'title' => 'Bof'},
          ]
        } }

        it 'loads the pagination info' do
          fetcher.queue {}
          Viki.run
          fetcher.more.should === true
          fetcher.count.should == 10
        end
      end
    end

    describe "caching" do
      let(:cache_seconds) { 5 }
      let(:fetcher) { Viki::Core::Fetcher.new("http://example.com/path", nil, {}, "json", {cache_seconds: cache_seconds}) }
      let(:cache) do
        {}.tap { |c|
          def c.setex(k, s, v)
            self[k] = v
          end

          def c.get(k)
            self[k]
          end

          def c.expire(k, s)
          end
        }
      end

      it "caches the API requests" do
        Viki.stub(:cache) { cache }
        fetcher.queue do
          fetcher.queue do
            WebMock.should have_requested("get", "http://example.com/path").once
          end
        end
      end

      it "doesn't cache if caching is not setup" do
        fetcher.queue do
          fetcher.queue do
            WebMock.should have_requested("get", "http://example.com/path").twice
          end
        end
      end

      it "doesn't cache if request has nocache=true" do
        stub_request("get", "http://example.com/path?nocache=true").
            to_return(body: Oj.dump(content, mode: :compat), status: status)
        nocache_fetcher = Viki::Core::Fetcher.new("http://example.com/path?nocache=true", nil, {}, {cache_seconds: 5})
        nocache_fetcher.queue do
          nocache_fetcher.queue do
            WebMock.should have_requested("get", "http://example.com/path?nocache=true").twice
          end
        end
      end

      it "doesn't cache response on timeout error" do
        Viki.stub(:cache) { cache }
        fetcher.stub(:is_error?).and_return(true)
        stub_request("get", "http://example.com/path").to_return(
          body: Oj.dump(content, mode: :compat),
          timed_out?: true
        )
        fetcher.queue do
        end
        Viki.cache.should_not_receive(:setex)
      end

      it "doesn't cache response on non-timeout error" do
        Viki.stub(:cache) { cache }
        fetcher.stub(:is_error?).and_return(true)
        stub_request("get", "http://example.com/path").to_return(
          body: Oj.dump(content, mode: :compat),
          timed_out?: false,
          code: 12345
        )
        fetcher.queue do
        end
        Viki.cache.should_not_receive(:setex)
      end

      it "doesn't cache response on json parse error" do
        Viki.stub(:cache) { cache }
        stub_request("get", "http://example.com/path").to_return(
          body: {},
          status: 200
        )
        fetcher.queue do
        end
        Viki.cache.should_not_receive(:setex)
      end

      it "ignores t, sig and token parameters" do
        Viki.stub(:cache) { cache }
        stub_request("get", "http://example.com/path?other=a&t=123&sig=abc&token=123").to_return(body: Oj.dump(content, mode: :compat), status: status)
        stub_request("get", "http://example.com/path?other=b&t=123&sig=abc&token=123").to_return(body: Oj.dump(content, mode: :compat), status: status)

        Viki::Core::Fetcher.new("http://example.com/path?other=a&t=123&sig=abc&token=123", nil, {}, {cache_seconds: 5}).queue do
          Viki::Core::Fetcher.new("http://example.com/path?other=b&t=123&sig=abc&token=123", nil, {}, {cache_seconds: 5}).queue do
            WebMock.should have_requested("get", "http://example.com/path?other=a&t=123&sig=abc&token=123").once
            WebMock.should have_requested("get", "http://example.com/path?other=b&t=123&sig=abc&token=123").once
          end
        end
      end

      it 'uses the last character of the user token for caching, ignoring the rest' do
        Viki.stub(:cache) { cache }
        stub_request("get", "http://example.com/path?token=1234_13").to_return(:body => Oj.dump(content))
        stub_request("get", "http://example.com/path?token=1234_13").to_return(:body => Oj.dump(content))

        Viki::Core::Fetcher.new("http://example.com/path?token=1234_13", nil, {}, 'json', {cache_seconds: 5}).queue do
          Viki::Core::Fetcher.new("http://example.com/path?token=1234_13", nil, {}, 'json', {cache_seconds: 5}).queue do
            WebMock.should have_requested("get", "http://example.com/path?token=1234_13").once
            WebMock.should have_requested("get", "http://example.com/path?token=1234_13").once
          end
        end
      end

      describe "Cache-Control header (for Fetcher taking in JSON)" do
        let(:cacheSeconds) { 5 }
        let(:fetchUrl) { "http://one.two/three" }
        let(:fetcher) {
          Viki::Core::Fetcher.new(fetchUrl, nil, {}, "json",
                                  { cache_seconds: cacheSeconds })
        }
        let(:content) { { "Title" => "iTerm2 is better than Terminal?"} }
        let(:newCache) {
          {}.tap { |c|
            def c.setex(key, time, value)
              self["cache-seconds"] = time
            end

            def c.get(k)
              self[k]
            end
          }
        }

        it "honors max-age in Cache-Control header when the resource is public" do
          Viki.stub(:cache) { newCache }
          stub_request("get", fetchUrl).to_return(
            body: Oj.dump(content, mode: :compat),
            status: 200,
            headers: { "Cache-Control" => "public, max-age=1793" }
          )

          fetcher.queue do
            newCache["cache-seconds"].should == 1793
          end
        end

        it "honors max-age in Cache-Control header when resource is public (shuffled order)" do
          Viki.stub(:cache) { newCache }
          stub_request("get", fetchUrl).to_return(
            body: Oj.dump(content, mode: :compat),
            status: 200,
            headers: { "Cache-Control" => "max-age=671, a useless string, public" }
          )

          fetcher.queue do
            newCache["cache-seconds"].should == 671
          end
        end

        it "does not use max-age in Cache-Control header when resource is not public" do
          Viki.stub(:cache) { newCache }
          stub_request("get", fetchUrl).to_return(
            body: Oj.dump(content, mode: :compat),
            status: 200,
            headers: { "Cache-Control" => "private, max-age=2046" }
          )

          fetcher.queue do
            newCache["cache-seconds"].should == cacheSeconds
          end
        end
      end

      describe "Cache-Control header (for Fetcher not taking in JSON)" do
        let(:cacheSeconds) { 5 }
        let(:fetchUrl) { "http://www.going.to.korea.com/" }
        let(:fetcher) {
          Viki::Core::Fetcher.new(fetchUrl, nil, {}, "notjson",
                                  { cache_seconds: cacheSeconds })
        }
        let(:content) { "iMacs are best used in low light conditions" }
        let(:newCache) {
          {}.tap { |c|
            def c.setex(k, time, v)
              self["cache-seconds"] = time
            end

            def c.get(k)
              self[k]
            end
          }
        }

        it "honors max-age in Cache-Control header when the resource is public" do
          Viki.stub(:cache) { newCache }
          stub_request("get", fetchUrl).to_return(
            body: content,
            status: 200,
            headers: { "Cache-Control" => "public, max-age=9861" }
          )

          fetcher.queue do
            newCache["cache-seconds"].should == 9861
          end
        end

        it "does not use max-age in Cache-Control header when resource is not public" do
          Viki.stub(:cache) { newCache }
          stub_request("get", fetchUrl).to_return(
            body: content,
            status: 200,
            headers: { "Cache-Control" => "private, max-age=12573" }
          )

          fetcher.queue do
            newCache["cache-seconds"].should == cacheSeconds
          end
        end
      end
    end
  end
end
