require 'spec_helper'

describe Viki::Review, api: true do
  it "fetches review of a container when container_id is specified" do
    stub_api 'containers/23203c/reviews.json', json_fixture(:reviews)
    described_class.fetch(container_id: "23203c") do |response|
      response.value.should be_a_kind_of(Array)
    end
  end

  it "fetches review languages when resource_id is specified" do
    stub_api 'reviews/languages.json', Oj.dump({ "en" => { "direction" => "ltr", "native_name" => "English","name" => { "en" => "English" } } })
    described_class.languages(resource_id: "23203c") do |response|
      response.value.should == { "en" => { "direction" => "ltr", "native_name" => "English","name" => { "en" => "English" } } }
    end
  end

  it "fetches review when user_id is specified" do
    stub_api 'users/9305492u/reviews.json', json_fixture(:reviews)
    described_class.fetch(user_id: "9305492u") do |response|
      response.value.should be_a_kind_of(Array)
    end
  end
end
