require 'spec_helper'

describe Viki::Flags, api: true do
  let (:flags_json) {
    {
      resource_id: '50c',
      flag: 'inappropriate'
    }
  }

  describe "POST" do
    it "create flags" do
      request = stub_request('post', %r{.*/v4/flags.json.*})
      described_class.create({}, flags_json) { |response| }
      Viki.run
      request.should have_been_made
    end
  end

  describe "DELETE" do
    it "delete flags" do
      request = stub_request('delete', %r{.*/v4/flags.json.*})
      described_class.destroy({resource_id: "50c"}) do
      end
      Viki.run
      request.should have_been_made
    end
  end
end
