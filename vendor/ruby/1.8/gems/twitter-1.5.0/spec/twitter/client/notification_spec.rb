require 'helper'

describe Twitter::Client do
  Twitter::Configuration::VALID_FORMATS.each do |format|
    context ".new(:format => '#{format}')" do
      before do
        @client = Twitter::Client.new(:format => format, :consumer_key => 'CK', :consumer_secret => 'CS', :oauth_token => 'OT', :oauth_token_secret => 'OS')
      end

      describe ".enable_notifications" do

        before do
          stub_post("notifications/follow.#{format}").
            with(:body => {:screen_name => "sferik"}).
            to_return(:body => fixture("sferik.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
        end

        it "should get the correct resource" do
          @client.enable_notifications("sferik")
          a_post("notifications/follow.#{format}").
            with(:body => {:screen_name => "sferik"}).
            should have_been_made
        end

        it "should return the specified user when successful" do
          user = @client.enable_notifications("sferik")
          user.name.should == "Erik Michaels-Ober"
        end

      end

      describe ".disable_notifications" do

        before do
          stub_post("notifications/leave.#{format}").
            with(:body => {:screen_name => "sferik"}).
            to_return(:body => fixture("sferik.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
        end

        it "should get the correct resource" do
          @client.disable_notifications("sferik")
          a_post("notifications/leave.#{format}").
            with(:body => {:screen_name => "sferik"}).
            should have_been_made
        end

        it "should return the specified user when successful" do
          user = @client.disable_notifications("sferik")
          user.name.should == "Erik Michaels-Ober"
        end
      end
    end
  end
end
