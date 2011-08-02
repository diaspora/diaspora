require 'helper'

describe Twitter::Client do
  Twitter::Configuration::VALID_FORMATS.each do |format|
    context ".new(:format => '#{format}')" do
      before do
        @client = Twitter::Client.new(:format => format, :consumer_key => 'CK', :consumer_secret => 'CS', :oauth_token => 'OT', :oauth_token_secret => 'OS')
      end

      describe ".direct_messages" do

        before do
          stub_get("direct_messages.#{format}").
            to_return(:body => fixture("direct_messages.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
        end

        it "should get the correct resource" do
          @client.direct_messages
          a_get("direct_messages.#{format}").
            should have_been_made
        end

        it "should return the 20 most recent direct messages sent to the authenticating user" do
          direct_messages = @client.direct_messages
          direct_messages.should be_an Array
          direct_messages.first.sender.name.should == "Erik Michaels-Ober"
        end

      end

      describe ".direct_messages_sent" do

        before do
          stub_get("direct_messages/sent.#{format}").
            to_return(:body => fixture("direct_messages.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
        end

        it "should get the correct resource" do
          @client.direct_messages_sent
          a_get("direct_messages/sent.#{format}").
            should have_been_made
        end

        it "should return the 20 most recent direct messages sent by the authenticating user" do
          direct_messages = @client.direct_messages_sent
          direct_messages.should be_an Array
          direct_messages.first.sender.name.should == "Erik Michaels-Ober"
        end

      end

      describe ".direct_message_create" do

        before do
          stub_post("direct_messages/new.#{format}").
            with(:body => {:screen_name => "pengwynn", :text => "Creating a fixture for the Twitter gem"}).
            to_return(:body => fixture("direct_message.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
        end

        it "should get the correct resource" do
          @client.direct_message_create("pengwynn", "Creating a fixture for the Twitter gem")
          a_post("direct_messages/new.#{format}").
            with(:body => {:screen_name => "pengwynn", :text => "Creating a fixture for the Twitter gem"}).
            should have_been_made
        end

        it "should return the sent message" do
          direct_message = @client.direct_message_create("pengwynn", "Creating a fixture for the Twitter gem")
          direct_message.text.should == "Creating a fixture for the Twitter gem"
        end

      end

      describe ".direct_message_destroy" do

        before do
          stub_delete("direct_messages/destroy/1825785544.#{format}").
            to_return(:body => fixture("direct_message.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
        end

        it "should get the correct resource" do
          @client.direct_message_destroy(1825785544)
          a_delete("direct_messages/destroy/1825785544.#{format}").
            should have_been_made
        end

        it "should return the deleted message" do
          direct_message = @client.direct_message_destroy(1825785544)
          direct_message.text.should == "Creating a fixture for the Twitter gem"
        end
      end
    end
  end
end
