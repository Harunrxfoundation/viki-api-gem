require 'spec_helper'

describe Viki::List, api: true do
  it "fetches single list" do
    VCR.use_cassette "Viki::List_one_list" do
      described_class.fetch(id: "1l") do |response|
        video = response.value
        video.should be_a_kind_of(Array)
        video.first.keys.should include('titles')
      end
      Viki.run
    end
  end
end
