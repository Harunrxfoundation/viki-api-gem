require "spec_helper"

describe Viki::Search, api: true do
  it "performs search" do
    stub_api "search.json", json_fixture(:search),
             params: {term: 'gangnam'}
    described_class.fetch(term: "gangnam") do |response|
      response.value.should be_a_kind_of(Array)
    end
  end
end
