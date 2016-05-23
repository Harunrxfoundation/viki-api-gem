require 'spec_helper'

describe Viki::CountryByResource, api: true do
  it "fetches movies countries" do
    stub_api 'movies/countries.json', json_fixture(:music_genres)
    described_class.fetch(resource: "movies") do |response|
      response.value.should be_a_kind_of(Array)
    end
  end

  it "fetches series genres" do
    stub_api 'series/countries.json', json_fixture(:music_genres)
    described_class.fetch(resource: "series") do |response|
      response.value.should be_a_kind_of(Array)
    end
  end

  it "fetches music_videos genres" do
    stub_api 'music_videos/countries.json', json_fixture(:music_genres)
    described_class.fetch(resource: "music_videos") do |response|
      response.value.should be_a_kind_of(Array)
    end
  end
end
