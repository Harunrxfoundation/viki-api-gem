require "spec_helper"

describe Viki::Genre, api: true do
  it "fetches movies genres" do
    stub_api 'movies/genres.json', json_fixture(:music_genres)
    described_class.fetch(resource: "movies") do |response|
      response.value.should be_a_kind_of(Array)
    end
  end

  it "fetches series genres" do
    stub_api 'series/genres.json', json_fixture(:music_genres)
    described_class.fetch(resource: "series") do |response|
      response.value.should be_a_kind_of(Array)
    end
  end

  it "fetches music_videos genres" do
    stub_api 'music_videos/genres.json', json_fixture(:music_genres)
    described_class.fetch(resource: "music_videos") do |response|
      response.value.should be_a_kind_of(Array)
    end
  end
end
