require 'spec_helper'

describe Viki::Container, api: true do
  describe 'list' do
    before { stub_api 'containers.json', json_fixture(:containers), api_version: "v4" }
    it_behaves_like "a container object"
  end

  it "fetches single container" do
    stub_api 'containers/1411c.json', json_fixture(:container), api_version: "v4"
    described_class.fetch(id: "1411c") do |response|
      video = response.value
      video.should be_a_kind_of(Hash)
      expect(video.keys).to include('titles')
      expect(video.keys).to include('verticals')
      expect(video.keys).to include('paywall')
    end
  end

  it "fetches recommendations for container" do
    resp = double
    Viki::Container.should_receive(:fetch).with(recommended_for: '50c').and_yield(resp)
    Viki::Container.recommendations('50c') do |res|
      res.should eq resp
    end
  end

  it "fetches people for container" do
    resp = double
    Viki::Container.should_receive(:fetch).with(people_for: '50c').and_yield(resp)
    Viki::Container.people('50c') do |res|
      res.should eq resp
    end
  end

  it "fetches tags for container" do
    resp = double
    Viki::Container.should_receive(:fetch).with(tags_for: '50c').and_yield(resp)
    Viki::Container.tags('50c') do |res|
      res.should eq resp
    end
  end

  describe "create" do
    it "makes a POST request to v4" do
      params = {app: Viki.app_id}
      stub_request("post", "http://api.dev.viki.io/v4/containers.json").
          with(query: hash_including(:sig, :t, params),
               headers: {'Content-Type' => 'application/json', 'User-Agent' => 'viki'},
               body: hash_including("key"=> "value")).
          to_return(body: '', status: 200)

      described_class.create({}, {"key" => "value"}) do |res|
        res.error.should be_nil
      end
    end
  end

  describe "create_sync" do
    it "makes a POST request to v4" do
      params = {app: Viki.app_id}
      stub_request("post", "http://api.dev.viki.io/v4/containers.json").
          with(query: hash_including(:sig, :t, params),
               headers: {'Content-Type' => 'application/json', 'User-Agent' => 'viki'},
               body: hash_including("key"=> "value")).
          to_return(body: '', status: 200)

      res = described_class.create_sync({}, {"key" => "value"})
      res.error.should be_nil
    end
  end

  describe "update" do
    it "makes a PUT request to v4" do
      params = {app: Viki.app_id}
      stub_request("put", "http://api.dev.viki.io/v4/containers/1c.json").
          with(query: hash_including(:sig, :t, params),
               headers: {'Content-Type' => 'application/json', 'User-Agent' => 'viki'},
               body: hash_including("key"=> "value")).
          to_return(body: '', status: 200)

      described_class.update({id: '1c'}, {"key" => "value"}) do |res|
        res.error.should be_nil
      end
    end
  end

  describe "update_sync" do
    it "makes a PUT request to v4" do
      params = {app: Viki.app_id}
      stub_request("put", "http://api.dev.viki.io/v4/containers/1c.json").
          with(query: hash_including(:sig, :t, params),
               headers: {'Content-Type' => 'application/json', 'User-Agent' => 'viki'},
               body: hash_including("key"=> "value")).
          to_return(body: '', status: 200)

      res = described_class.update_sync({id: '1c'}, {"key" => "value"})
      res.error.should be_nil
    end
  end

  describe "destroy" do
    it "makes a DELETE request to v4" do
      params = {app: Viki.app_id}
      stub_request("delete", "http://api.dev.viki.io/v4/containers/1c.json").
          with(query: hash_including(:sig, :t, params),
               headers: {'Content-Type' => 'application/json', 'User-Agent' => 'viki'}).
          to_return(status: 200, :body => "", :headers => {})

      described_class.destroy({id: '1c'}) do |res|
        res.error.should be_nil
      end
    end
  end

  describe "destroy_sync" do
    it "makes a PUT request to v4" do
      params = {app: Viki.app_id}
      stub_request("delete", "http://api.dev.viki.io/v4/containers/1c.json").
          with(query: hash_including(:sig, :t, params),
               headers: {'Content-Type' => 'application/json', 'User-Agent' => 'viki'}).
          to_return(body: '', status: 200, :headers => {})

      res = described_class.destroy_sync({id: '1c'})
      res.error.should be_nil
    end
  end
end
