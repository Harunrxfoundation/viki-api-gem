require 'spec_helper'

describe Viki::Language, api: true do
  it "fetches the countries from the API" do
    VCR.use_cassette "Viki::Language_fetch" do
      Viki::Language.find('it')["native_name"].should == "Italiano"
      Viki::Language.codes.should include 'it'
    end
  end
end
