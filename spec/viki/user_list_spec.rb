require 'spec_helper'

describe Viki::UserList, api: true do
  it 'fetches all lists' do
    stub_api 'user-lists.json', json_fixture(:user_lists), { https: true }

    described_class.fetch do |response|
      values = response.value
      values.count.should == 2

      values.first['id'].should == '1l'
      values.last['id'].should == '3l'
    end
  end

  it 'create list' do

  end

  it 'fetch a list' do

  end

  it 'delete a list' do

  end

  it 'add an element to the end of the list' do

  end

  it 'delete an element from a list' do

  end
end
