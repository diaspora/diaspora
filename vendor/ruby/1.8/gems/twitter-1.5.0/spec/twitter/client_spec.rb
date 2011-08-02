require 'helper'

describe Twitter::Client do
  it "should connect using the endpoint configuration" do
    client = Twitter::Client.new
    endpoint = URI.parse(client.api_endpoint)
    connection = client.send(:connection).build_url(nil).to_s
    connection.should == endpoint.to_s
  end

  it "should not cache the screen name across clients" do
    stub_get("account/verify_credentials.json").
      to_return(:body => fixture("sferik.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    client1 = Twitter::Client.new(:oauth_token => 'ot1', :oauth_token_secret => 'ots1')
    client1.send(:get_screen_name).should == "sferik"
    stub_get("account/verify_credentials.json").
      to_return(:body => fixture("pengwynn.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    client2 = Twitter::Client.new(:oauth_token => 'ot2', :oauth_token_secret => 'ots2')
    client2.send(:get_screen_name).should == "pengwynn"
  end
end
