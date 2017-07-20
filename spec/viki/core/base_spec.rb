require 'spec_helper'

describe Viki::Core::Base do
  let(:test_klass) {
    Class.new(described_class) do
      path "/path/to/resource"
      path "/manage/:an_id/resource", manage: true
    end
  }

  describe "#uri" do
    let(:nested_test_klass) {
      Class.new(described_class) do
        path "/other/:other_id/parent/:parent_id/resource"
        path "/parent/:parent_id/resource"
      end
    }

    let(:named_paths_test_klass) {
      Class.new(described_class) do
        path "/other/:other_id/parent/:parent_id/resource", name: "path1"
        path "/parent/:parent_id/resource", name: "path1"
        path "/useless/:useless_id/resource", name: "path2"
        path "/default/:default_id/resource"
      end
    }

    subject { test_klass.uri }

    its(:authority) { should == Viki.domain }
    its(:path) { should == "/v4/path/to/resource.json" }

    it 'includes the app' do
      subject.query_values["app"].should == Viki.app_id
    end

    it 'includes the app' do
      url = test_klass.uri(app: '9001').to_s
      url.should match("app=9001")
    end

    it "includes the options" do
      url = test_klass.uri(hello: 'world').to_s
      url.to_s.should ==  "http://api.dev.viki.io/v4/path/to/resource.json?app=70000a&hello=world"
    end

    it "doesn't include the options used to replace the path" do
      url = test_klass.uri(id: 'world').to_s
      url.should_not match("=world")
    end

    it "includes the 'id' param as a resource url" do
      test_klass.uri(id: 'object_id').path.should == "/v4/path/to/resource/object_id.json"
    end

    it "replaces the parents ids for nested resources" do
      path = nested_test_klass.uri(parent_id: 'parent_id').path
      path.should == "/v4/parent/parent_id/resource.json"
    end

    it "uses the path with more matches" do
      nested_test_klass.uri(parent_id: 'parent_id', fail: "1").path.should ==
        "/v4/parent/parent_id/resource.json"
      nested_test_klass.uri(other_id: 'other_id', parent_id: 'parent_id').path.should ==
        "/v4/other/other_id/parent/parent_id/resource.json"
    end

    it "uses named paths" do
      named_paths_test_klass.uri(other_id: '123', parent_id: '234', named_path: 'path1').path.should ==
        "/v4/other/123/parent/234/resource.json"
      named_paths_test_klass.uri(parent_id: '234', named_path: 'path1').path.should ==
        "/v4/parent/234/resource.json"

      expect { named_paths_test_klass.uri(useless_id: '234', named_path: 'path1') }.to raise_error(Viki::Core::Base::InsufficientOptions)
      expect { named_paths_test_klass.uri(default_id: '234', named_path: 'path1') }.to raise_error(Viki::Core::Base::InsufficientOptions)
      expect { named_paths_test_klass.uri(named_path: 'path2') }.to raise_error(Viki::Core::Base::InsufficientOptions)

      named_paths_test_klass.uri(useless_id: '234', named_path: 'path2').path.should ==
        "/v4/useless/234/resource.json"
    end

    it "uses default value if required value is not provided" do
      nested_test_klass.default parent_id: 'default_value'
      nested_test_klass.uri(other_id: 'other_id').path.should == "/v4/other/other_id/parent/default_value/resource.json"
      nested_test_klass.uri.path.should == "/v4/parent/default_value/resource.json"
    end

    it "requires the parents for nested resources" do
      expect { nested_test_klass.uri }.to raise_error(Viki::Core::Base::InsufficientOptions)
    end

    it "includes the user token" do
      Viki.stub(:user_token) { lambda { '12345' } }
      test_klass.uri.to_s.should match("token=12345")
    end

    it "does not include the user token if it's empty" do
      Viki.stub(:user_token) { lambda { '' } }
      test_klass.uri.to_s.should_not match("token=")
    end

    it 'uses https for ssl' do
      test_klass._ssl = true
      test_klass.uri.to_s.should start_with("https")
      test_klass._ssl = false
      test_klass.uri.to_s.should_not start_with("https")
    end

    describe "manage" do
      it "can use manage domain" do
        url = test_klass.uri(container_id: '50c', manage: true)
        url.to_s.should == "http://manage.dev.viki.io/v4/path/to/resource.json?app=70000a&container_id=50c"
      end

      it "can access a manage domain with manage" do
        url = test_klass.uri(an_id: '50c', manage: true)
        url.to_s.should == "http://manage.dev.viki.io/v4/manage/50c/resource.json?app=70000a"
      end

      it "cannot access a manage domain without manage" do
        url = test_klass.uri(an_id: '50c')
        url.to_s.should == "http://api.dev.viki.io/v4/path/to/resource.json?an_id=50c&app=70000a"
      end
    end
  end

  describe "#is_cacheable?" do
    it 'make sure that default is always not cacheable' do
      expect(test_klass.is_cacheable?).to eq false
    end

    it 'make sure that default is cacheable if no cacheable values is sent' do
      test_klass.cacheable
      expect(test_klass.is_cacheable?).to eq true
    end

    it 'make sure that default is cacheable if cacheable values are sent' do
      test_klass.cacheable({ cache_seconds: 30 })
      expect(test_klass.is_cacheable?).to eq true
    end
  end

  describe "#cacheable" do
    it 'make sure that cacheable parameters are set when called' do
      test_klass.cacheable({ cache_seconds: 52 })
      expect(test_klass._is_cacheable).to eq true
      expect(test_klass._cacheable).to eq({cache_seconds: 52})
    end

    it 'make sure that cacheable parameters are set when called even with no timing' do
      test_klass.cacheable
      expect(test_klass._is_cacheable).to eq true
      expect(test_klass._cacheable).to be_nil
    end
  end

  describe "#cacheable_payload" do
    it 'returns default payload if cacheable timing is not set' do
      test_klass.cacheable
      expect(test_klass.cacheable_payload).to eq({cache_seconds: 5})
      # Dynamically set default cache_seconds payload - this occurs during
      # Viki.configure for client apps - which replaces the default
      Viki.should_receive(:cache_seconds).and_return(14)
      expect(test_klass.cacheable_payload).to eq({cache_seconds: 14})
    end

    it 'returns immutable payload if cacheable timing is set' do
      test_klass.cacheable({ cache_seconds: 35 })
      expect(test_klass.cacheable_payload).to eq({cache_seconds: 35})
      # Test mutability
      Viki.should_not_receive(:cache_seconds)
      expect(test_klass.cacheable_payload).to eq({cache_seconds: 35})
    end
  end

  describe "#signed_uri" do
    let(:uri) { Addressable::URI.parse "http://example.com" }
    let(:body) { "" }
    before { test_klass.should_receive(:uri) { uri } }

    subject { test_klass.signed_uri }

    its(:query_values) { should have_key("t") }
    its(:query_values) { should have_key("sig") }
  end

  describe "#get_signed_uri" do
    let(:uri) { Addressable::URI.parse "http://example.com" }
    let(:original_params) { { secret: 'meh' } }
    let(:input_params) { original_params.dup }

    def subject
      test_klass.get_signed_uri(input_params)
    end

    it "makes sure input params' values are preserved" do
      subject
      input_params.should == original_params
    end

    it 'returns the same url as it passed to #signed_uri' do
      subject.should == test_klass.signed_uri(input_params)
    end
  end

  describe "#signed_uri override" do
    it 'uses the provided secret' do
      double = double('signer')
      Viki::UriSigner.should_receive(:new).with('9001').and_return(double)
      double.should_receive(:sign_request).with('http://api.dev.viki.io/v4/path/to/resource.json?app=70000a', nil).and_return('blah?test')
      url = test_klass.signed_uri(secret: '9001').to_s
      url.should == "blah?test"
    end
  end

  describe "#fetch" do
    it "constructs a fetcher from the signed_uri" do
      uri = double
      options = double
      headers = {}
      options.should_receive(:[]).with(:format).and_return "json"
      test_klass.should_receive(:signed_uri).with(options) { uri }
      Viki::Core::Fetcher.should_receive(:new).with(uri, nil, headers, 'json') { double :queue => nil }
      test_klass.fetch(options) do
      end
    end

    it "contructs a fetcher initializer with cacheble option when cacheable is present" do
      test_klass.cacheable
      uri = double
      options = double
      headers = {}
      options.should_receive(:[]).with(:format).and_return "json"
      test_klass.should_receive(:signed_uri).with(options) { uri }
      Viki::Core::Fetcher.should_receive(:new).with(uri, nil, headers, 'json', {cache_seconds: 5}) { double :queue => nil }
      test_klass.fetch(options) {}
    end

    it "cacheable can accept argument for cache expiry time" do
      test_klass.cacheable(cache_seconds: 30)
      uri = double
      options = double
      headers = {}
      options.should_receive(:[]).with(:format).and_return "json"
      test_klass.should_receive(:signed_uri).with(options) { uri }
      Viki::Core::Fetcher.should_receive(:new).with(uri, nil, headers, 'json', {cache_seconds: 30}) { double :queue => nil }
      test_klass.fetch(options) {}
    end
  end

  describe "#create" do
    it "constructs a creator from the signed_uri and the body" do
      uri = double
      options = double
      options.should_receive(:[]).with(:format).and_return "json"
      body = double.as_null_object
      headers = {}
      test_klass.should_receive(:signed_uri).with(options, body) { uri }
      Viki::Core::Creator.should_receive(:new).with(uri, body, headers, 'json') { double :queue => nil }
      test_klass.create(options, body) do
      end
    end
  end

  describe "#update" do
    it "constructs a updater from the signed_uri and the body" do
      uri = double
      options = double
      options.should_receive(:[]).with(:format).and_return "json"
      body = double.as_null_object
      headers = {}
      test_klass.should_receive(:signed_uri).with(options, body) { uri }
      Viki::Core::Updater.should_receive(:new).with(uri, body, headers, 'json') { double :queue => nil }
      test_klass.update(options, body) do
      end
    end
  end

  describe "#destroy" do
    it "constructs a destroyer from the signed_uri" do
      uri = double
      options = double
      options.should_receive(:[]).with(:format).and_return "json"
      body = double.as_null_object
      headers = {}
      test_klass.should_receive(:signed_uri).with(options, body) { uri }
      Viki::Core::Destroyer.should_receive(:new).with(uri, body, headers, "json") { double :queue => nil }
      test_klass.destroy(options, body) do
      end
    end
  end

  describe "#patcher" do
    it "constructs a patch request from the signed_uri and the body" do
      uri = double
      options = double
      options.should_receive(:[]).with(:format).and_return "json"
      body = double.as_null_object
      headers = {}
      test_klass.should_receive(:signed_uri).with(options, body) { uri }
      Viki::Core::Patcher.should_receive(:new).with(uri, body, headers, 'json') { double :queue => nil }
      test_klass.patch(options, body) do
      end
    end
  end

  describe "#headers" do
    it "sets default headers as an empty hash" do
      expect(test_klass.headers).to eq({})
    end

    it "sets headers if the corresponding lambda was defined by the client" do
      Viki.should_receive(:addon_headers).and_return(lambda { { 'test_header' => 'value test' } })
      expect(test_klass.headers).to eq({ 'test_header' => 'value test' })
    end
  end

  describe "#is_ssl_enabled?" do
    it 'initializes with ssl option' do
      Viki.configure do |c|
        c.ssl = true
      end

      expect(Viki::Core::Base.is_ssl_enabled?).to eq true
    end

    describe 'initializes without ssl option' do
      before(:each) do
        Viki.configure do |c|
          c.ssl = false
        end
      end

      it 'use_ssl is called' do
        Viki::Core::Base.use_ssl
        expect(Viki::Core::Base.is_ssl_enabled?).to eq true
      end

      it 'use_ssl is not called' do
        Viki::Core::Base._ssl = false
        expect(Viki::Core::Base.is_ssl_enabled?).to eq false
      end
    end
  end
end
