require 'spec_helper'

describe Viki::PurchasablePlanInvoice, api: true do
  it "gets an invoice for a purchasable plans of the current user" do
    stub = stub_request('get', %r{.*/purchasable_plans/21p/invoice.json.*})

    described_class.fetch({ plan_id: "21p" }) do
    end
    Viki.run
    stub.should have_been_made
  end
end
