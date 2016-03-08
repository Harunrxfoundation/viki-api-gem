require 'spec_helper'

describe Viki::WatchMarker, api: true do
  it 'should fetch list of watch markers' do
    stub_api 'users/1u/watch_markers.json', json_fixture(:watch_marker), api_version: 'v4'
    
    watch_markers = nil
    described_class.fetch(id: '1u') { |res| watch_markers = res.value }
    Viki.run
    
    watch_markers["markers"].should be_a_kind_of(Array)
    watch_markers["markers"][0]["video_id"].should eq "1073616v"
  end 

  it 'should fetch list with given timestamp' do
    stub_api 'users/1u/watch_markers.json', json_fixture(:watch_marker), api_version: 'v4'
    
    watch_markers = nil
    described_class.should_receive(:fetch).with(id: '1u', from: 1455950940)

    described_class.fetch(id: '1u', from: 1455950940) { |res| watch_markers = res.value }
    Viki.run
  end 
end