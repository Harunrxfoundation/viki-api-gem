require 'spec_helper'

describe Viki::Video, api: true do
  # it "fetches single videos" do
  #   stub_api 'videos/11501v.json', json_fixture(:video)
  #   described_class.fetch(id: "11501v") do |response|
  #     video = response.value
  #     video.should be_a_kind_of(Hash)
  #     video.keys.should include('titles')
  #   end
  # end

  it "create videos via containers/:container_id/videos" do
    stub_api 'containers/42c/videos.json', json_fixture(:video), {method: :post, api_version: "v4"}
    described_class.create({container_id: "42c"}, {}) do |response|
      video = response.value
      video.should be_a_kind_of(Hash)
      video.keys.should include('titles')
    end
  end

  # it "updates videos via containers/:container_id/videos/:video_id.json" do
  #   stub_api 'containers/42c/videos/42v.json', json_fixture(:video), {method: :put}
  #   described_class.update({container_id: "42c", video_id: "42v"}, {}) do |response|
  #     video = response.value
  #     video.should be_a_kind_of(Hash)
  #     video.keys.should include('titles')
  #   end
  # end

  # it "updates videos via videos/:id.json" do
  #   stub_api 'videos/42v.json', json_fixture(:video), { method: :put }
  #   described_class.update({ id: "42v" }, { }) do |response|
  #     video = response.value
  #     video.should be_a_kind_of(Hash)
  #     video.keys.should include('titles')
  #   end
  # end

  it "fetches tags for container" do
    resp = double
    Viki::Video.should_receive(:fetch).with(tags_for: '50c').and_yield(resp)
    Viki::Video.tags('50c') do |res|
      res.should eq resp
    end
  end
end
