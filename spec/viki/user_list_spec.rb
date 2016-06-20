require 'spec_helper'
require 'json'

describe Viki::UserList, api: true do
  let (:list_json) {
    {
      "id": "1l",
      "titles": {
        "ms": "Laman Utama",
        "en": "Homepage"
      },
      "images": {},
      "resource_type": "any",
      "list_type": "viki",
      "featured": false,
      "hidden_status": false,
      "private": false,
      "privacy": "public",
      "created_at": "2013-04-04T01:31:55Z",
      "updated_at": "2016-04-07T07:48:27Z",
      "stats": {
        "flags": {
          "total": 0
        },
        "subscriptions": {
          "total": 0
        }
      },
      "resource_count": 92
    }
  }

  it 'fetches all lists' do
    stub_api 'user-lists.json', json_fixture(:user_lists), https: true

    described_class.fetch do |response|
      values = response.value
      values.count.should == 2

      values.first['id'].should == '1l'
      values.last['id'].should == '3l'
    end
  end

  it 'create list' do # POST
    request = stub_api 'user-lists.json', nil, method: :post, https: true,response_code: 201

    described_class.create({}, list_json) { |response| }
    Viki.run

    request.should have_been_made
  end

  it 'fetch a list' do # GET
    stub_api 'user-lists/1l.json', list_json.to_json, https: true

    value = nil
    described_class.fetch(list_id: '1l') do |response|
      value = response.value
    end
    Viki.run

    value['id'].should == '1l'
  end

  it 'delete a list' do # DELETE
    stub_api 'user-lists/1l.json', nil, method: :delete, https: true

    value = nil
    described_class.destroy(list_id: '1l') do |response|
      response.error.should be_nil
    end
  end
end
