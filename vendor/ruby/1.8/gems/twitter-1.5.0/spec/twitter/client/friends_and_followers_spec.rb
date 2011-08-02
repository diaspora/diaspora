require 'helper'

describe Twitter::Client do
  Twitter::Configuration::VALID_FORMATS.each do |format|
    context ".new(:format => '#{format}')" do
      before do
        @client = Twitter::Client.new(:format => format, :consumer_key => 'CK', :consumer_secret => 'CS', :oauth_token => 'OT', :oauth_token_secret => 'OS')
      end

      describe ".friend_ids" do

        context "with a screen_name passed" do

          before do
            stub_get("friends/ids.#{format}").
              with(:query => {:screen_name => "sferik", :cursor => "-1"}).
              to_return(:body => fixture("id_list.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
          end

          it "should get the correct resource" do
            @client.friend_ids("sferik")
            a_get("friends/ids.#{format}").
              with(:query => {:screen_name => "sferik", :cursor => "-1"}).
              should have_been_made
          end

          it "should return an array of numeric IDs for every user the specified user is following" do
            id_list = @client.friend_ids("sferik")
            id_list.ids.should be_an Array
            id_list.ids.first.should == 146197851
          end

        end

        context "without arguments passed" do

          before do
            stub_get("friends/ids.#{format}").
              with(:query => {:cursor => "-1"}).
              to_return(:body => fixture("id_list.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
          end

          it "should get the correct resource" do
            @client.friend_ids
            a_get("friends/ids.#{format}").
              with(:query => {:cursor => "-1"}).
              should have_been_made
          end

          it "should return an array of numeric IDs for every user the specified user is following" do
            id_list = @client.friend_ids
            id_list.ids.should be_an Array
            id_list.ids.first.should == 146197851
          end

        end

      end

      describe ".follower_ids" do

        context "with a screen_name passed" do

          before do
            stub_get("followers/ids.#{format}").
              with(:query => {:screen_name => "sferik", :cursor => "-1"}).
              to_return(:body => fixture("id_list.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
          end

          it "should get the correct resource" do
            @client.follower_ids("sferik")
            a_get("followers/ids.#{format}").
              with(:query => {:screen_name => "sferik", :cursor => "-1"}).
              should have_been_made
          end

          it "should return an array of numeric IDs for every user following the specified user" do
            id_list = @client.follower_ids("sferik")
            id_list.ids.should be_an Array
            id_list.ids.first.should == 146197851
          end

        end

        context "without arguments passed" do

          before do
            stub_get("followers/ids.#{format}").
              with(:query => {:cursor => "-1"}).
              to_return(:body => fixture("id_list.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
          end

          it "should get the correct resource" do
            @client.follower_ids
            a_get("followers/ids.#{format}").
              with(:query => {:cursor => "-1"}).
              should have_been_made
          end

          it "should return an array of numeric IDs for every user following the specified user" do
            id_list = @client.follower_ids
            id_list.ids.should be_an Array
            id_list.ids.first.should == 146197851
          end
        end
      end
    end
  end
end
