require 'spec_helper'
require 'json'

describe Viki::UserListItem, api: true do
  let (:item_json) {
    {
      "resources": [
        "1v", "2v"
      ],
      "resources_details": [
        {
          "resource_id": "1v",
          "description": "test",
          "language": "en"
        },
        {
          "resource_id": "2v",
          "description": "test",
          "language": "en"
        }
      ]
    }
  }

  it 'adds an element to the end of the list' do # PATCH
    stub_api 'user-lists/1l/items.json', nil, method: :patch, https: true

    described_class.patch({list_id: '1l'}, item_json) do |response|
      response.error.should be_nil
    end
  end

  it 'removes an element from a list' do # DELETE
  end
end

