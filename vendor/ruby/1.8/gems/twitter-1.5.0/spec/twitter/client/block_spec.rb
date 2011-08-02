require 'helper'

describe Twitter::Client do
  Twitter::Configuration::VALID_FORMATS.each do |format|
    context ".new(:format => '#{format}')" do
      before do
        @client = Twitter::Client.new(:format => format, :consumer_key => 'CK', :consumer_secret => 'CS', :oauth_token => 'OT', :oauth_token_secret => 'OS')
      end

      describe ".block" do

        before do
          stub_post("blocks/create.#{format}").
            with(:body => {:screen_name => "sferik"}).
            to_return(:body => fixture("sferik.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
        end

        it "should get the correct resource" do
          @client.block("sferik")
          a_post("blocks/create.#{format}").
            should have_been_made
        end

        it "should return the blocked user" do
          user = @client.block("sferik")
          user.name.should == "Erik Michaels-Ober"
        end

      end

      describe ".unblock" do

        before do
          stub_delete("blocks/destroy.#{format}").
            with(:query => {:screen_name => "sferik"}).
            to_return(:body => fixture("sferik.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
        end

        it "should get the correct resource" do
          @client.unblock("sferik")
          a_delete("blocks/destroy.#{format}").
            with(:query => {:screen_name => "sferik"}).
            should have_been_made
        end

        it "should return the un-blocked user" do
          user = @client.unblock("sferik")
          user.name.should == "Erik Michaels-Ober"
        end

      end

      describe ".block_exists?" do

        before do
          stub_get("blocks/exists.#{format}").
            with(:query => {:screen_name => "sferik"}).
            to_return(:body => fixture("sferik.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
          stub_get("blocks/exists.#{format}").
            with(:query => {:screen_name => "pengwynn"}).
            to_return(:body => fixture("not_found.#{format}"), :status => 404, :headers => {:content_type => "application/#{format}; charset=utf-8"})
        end

        it "should get the correct resource" do
          @client.block_exists?("sferik")
          a_get("blocks/exists.#{format}").
            with(:query => {:screen_name => "sferik"}).
            should have_been_made
        end

        it "should return true if block exists" do
          block_exists = @client.block_exists?("sferik")
          block_exists.should be_true
        end

        it "should return false if block does not exists" do
          block_exists = @client.block_exists?("pengwynn")
          block_exists.should be_false
        end

      end

      describe ".blocking" do

        before do
          stub_get("blocks/blocking.#{format}").
            to_return(:body => fixture("users.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
        end

        it "should get the correct resource" do
          @client.blocking
          a_get("blocks/blocking.#{format}").
            should have_been_made
        end

        it "should return an array of user objects that the authenticating user is blocking" do
          users = @client.blocking
          users.should be_an Array
          users.first.name.should == "Erik Michaels-Ober"
        end

      end

      describe ".blocked_ids" do

        before do
          stub_get("blocks/blocking/ids.#{format}").
            to_return(:body => fixture("ids.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
        end

        it "should get the correct resource" do
          @client.blocked_ids
          a_get("blocks/blocking/ids.#{format}").
            should have_been_made
        end

        it "should return an array of numeric user ids the authenticating user is blocking" do
          ids = @client.blocked_ids
          ids.should be_an Array
          ids.first.should == 47
        end
      end
    end
  end
end
