require 'spec_helper'

describe Viki::Drm, api: true do
  it "fetches a single stream" do
    stub_api 'videos/44699v/drm.json', json_fixture(:drm)
    described_class.fetch(video_id: "44699v") do |response|
      drm = response.value
      drm.should be_a_kind_of(Hash)
      drm.keys.should include('drm_info')
    end
  end
end
