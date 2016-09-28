require 'spec_helper'

describe Viki::Recaps, api: true do
  it 'fetches recaps for a video when video_id is specified' do
    stub_api 'recaps.json', json_fixture(:recaps)
    described_class.fetch(video_id: '123v', language: 'en', source: 'all') do |response|
      values = response.value
      values.should be_a_kind_of(Array)
      values.first['id'].should == '1re'
    end
  end

  it 'creates a recap' do
    stub = stub_request('post', %r{.*/v4/recaps.json}).with(:body => { video_id: '1234v', title: 'Sample Show: Episode 1', preview_text: 'Introductory text goes here...' })
    described_class.create_recap({ video_id: '1234v', title: 'Sample Show: Episode 1', preview_text: 'Introductory text goes here...' }) do
    end
    Viki.run
    stub.should have_been_made
  end

  it 'updates  a recap' do
    stub = stub_request('patch', %r{.*/recaps/1re.json.*}).with(:body => { title: 'Sample Show: Episode 1', preview_text: 'Introductory text goes here...' })
    described_class.update_recap('1re', { title: 'Sample Show: Episode 1', preview_text: 'Introductory text goes here...' }) do
    end
    Viki.run
    stub.should have_been_made
  end

  it 'deletes  a recap' do
    stub = stub_request('delete', %r{.*/recaps/1re.json.*})
    described_class.delete_recap('1re') do
    end
    Viki.run
    stub.should have_been_made
  end
end
