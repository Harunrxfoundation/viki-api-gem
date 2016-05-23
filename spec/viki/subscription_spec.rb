require 'spec_helper'

describe Viki::Subscription, api: true do

  describe "for a user" do
    it "fetches subscriptions" do
      stub_api 'users/123u/subscriptions.json', '["1v", "2v"]'
      videos = nil
      described_class.fetch(user_id: "123u") { |response| videos = response.value }
      Viki.run
      videos.should == ["1v", "2v"]
    end

    it "creates subscriptions" do
      stub = stub_request('post', %r{.*/users/1u/subscriptions.json.*}).
        with(body: Oj.dump({'resource_id' => "2c"}))

      described_class.create({user_id: "1u"}, {'resource_id' => "2c"}) do
      end
      Viki.run
      stub.should have_been_made
    end

    it "deletes subscriptions" do
      stub = stub_request('delete', %r{.*/users/1u/subscriptions/2c.json.*})

      described_class.destroy({user_id: "1u", id: "2c"}) do
      end
      Viki.run
      stub.should have_been_made
    end
  end

  describe "for a container" do
    it "fetches subscriptions" do
      stub_api 'containers/1c/subscriptions.json', '{"data": "some_data"}', manage: true
      data = nil
      described_class.fetch(container_id: "1c", manage: true) do |response|
        data = response.value
      end
      Viki.run
      data.should == {"data" => "some_data"}
    end

    it "fails if its not manage" do
      stub_api 'containers/1c/subscriptions.json', 'some_data'
      expect {
        described_class.fetch(container_id: "1c")
      }.to raise_error(Viki::Core::Base::InsufficientOptions)
    end
  end
end
