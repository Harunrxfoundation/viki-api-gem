require 'spec_helper'

describe Viki::List, api: true do
  it "fetches single list" do
    stub_api 'lists/1l.json', json_fixture(:list_1l)
    described_class.fetch(id: "1l") do |response|
      video = response.value
      video.should be_a_kind_of(Array)
    end
  end

  it "creates list" do
    stub = stub_request('post', %r{.*/v4/lists.json}).with({titles: {en: 'Summer Collection'}})
    described_class.create({}, {titles: {en: 'Summer Collection'}}) do
    end
    Viki.run
    stub.should have_been_made
  end

  it "updates list" do
    stub = stub_request('put', %r{.*/v4/lists/1l.json}).with({titles: {en: 'Summer Collection'}})
    described_class.update({id: "1l"}, {titles: {en: 'Summer Collection'}}) do
    end
    Viki.run
    stub.should have_been_made
  end

  it "patches list" do
    stub = stub_request('patch', %r{.*/v4/lists/1l.json}).with({titles: {en: 'Summer Collection'}})
    described_class.patch({id: "1l"}, {titles: {en: 'Summer Collection'}}) do
    end
    Viki.run
    stub.should have_been_made
  end

  it "deletes list" do
    stub = stub_request('delete', %r{.*/v4/lists/1l.json})
    described_class.destroy({id: "1l"}) do
    end
    Viki.run
    stub.should have_been_made
  end
end
