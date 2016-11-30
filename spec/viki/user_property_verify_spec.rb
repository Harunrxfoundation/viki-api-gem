require 'spec_helper'

describe Viki::UserPropertyVerify, api: true do
  it "post request to resend verification token" do
    stub = stub_request('post', %r{.*/users/3u/verify.json}).
      with(:body => {"property" =>"email"},
           :headers => {'Content-Type'=>'application/json', 'User-Agent'=>'viki'}).
      to_return(body: '', status: 201)
    described_class.resend_verification_token('3u', '123t', {'property' => 'email' }) do |response|
      response.error.should be_nil
    end
    Viki.run
    stub.should have_been_made
  end

  it "post request to resend token" do
    stub = stub_request('post', %r{.*/users/3u/verify.json}).
      with(:body => {"property" =>"email"},
           :headers => {'Content-Type'=>'application/json', 'User-Agent'=>'viki'}).
      to_return(body: '', status: 201)
    described_class.resend_token('3u', {'property' => 'email' }) do |response|
      response.error.should be_nil
    end
    Viki.run
    stub.should have_been_made
  end

  it "put request to verify token" do
    user_details = {"property" =>"email",
                      "value"   =>"example@viki.com",
                      "verification_token" =>"123"}
    stub = stub_request('put', %r{.*/users/3u/verify.json}).
      with(:body => user_details,
           :headers => {'Content-Type'=>'application/json', 'User-Agent'=>'viki'}).
      to_return(body: '', status: 201)
    described_class.verify_token('3u',user_details) do |response|
      response.error.should be_nil
    end
    Viki.run
    stub.should have_been_made
  end
end
