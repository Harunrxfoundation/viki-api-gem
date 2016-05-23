require 'spec_helper'

describe Viki::LanguageByResource, api: true do
  it "fetches movies languages" do
    stub_api 'movies/languages.json', json_fixture(:music_genres)
    described_class.fetch(resource: "movies") do |response|
      response.value.should be_a_kind_of(Array)
    end
  end

  it "fetches series languages" do
    stub_api 'series/languages.json', json_fixture(:music_genres)
    described_class.fetch(resource: "series") do |response|
      response.value.should be_a_kind_of(Array)
    end
  end

  it "fetches music_videos languages" do
    stub_api 'music_videos/languages.json', json_fixture(:music_genres)
    described_class.fetch(resource: "music_videos") do |response|
      response.value.should be_a_kind_of(Array)
    end
  end
end
