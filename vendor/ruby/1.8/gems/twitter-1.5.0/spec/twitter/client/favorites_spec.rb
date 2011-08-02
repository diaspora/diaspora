require 'helper'

describe Twitter::Client do
  Twitter::Configuration::VALID_FORMATS.each do |format|
    context ".new(:format => '#{format}')" do
      before do
        @client = Twitter::Client.new(:format => format, :consumer_key => 'CK', :consumer_secret => 'CS', :oauth_token => 'OT', :oauth_token_secret => 'OS')
      end

      describe ".favorites" do

        context "with a screen name passed" do

          before do
            stub_get("favorites/sferik.#{format}").
              to_return(:body => fixture("favorites.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
          end

          it "should get the correct resource" do
            @client.favorites("sferik")
            a_get("favorites/sferik.#{format}").
              should have_been_made
          end

          it "should return the 20 most recent favorite statuses for the authenticating user or user specified by the ID parameter" do
            favorites = @client.favorites("sferik")
            favorites.should be_an Array
            favorites.first.user.name.should == "Zach Brock"
          end

        end

        context "without arguments passed" do

          before do
            stub_get("favorites.#{format}").
              to_return(:body => fixture("favorites.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
          end

          it "should get the correct resource" do
            @client.favorites
            a_get("favorites.#{format}").
              should have_been_made
          end

          it "should return the 20 most recent favorite statuses for the authenticating user or user specified by the ID parameter" do
            favorites = @client.favorites
            favorites.should be_an Array
            favorites.first.user.name.should == "Zach Brock"
          end

        end

      end

      describe ".favorite_create" do

        before do
          stub_post("favorites/create/25938088801.#{format}").
            to_return(:body => fixture("status.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
        end

        it "should get the correct resource" do
          @client.favorite_create(25938088801)
          a_post("favorites/create/25938088801.#{format}").
            should have_been_made
        end

        it "should return the favorite status when successful" do
          status = @client.favorite_create(25938088801)
          status.text.should == "@noradio working on implementing #NewTwitter API methods in the twitter gem. Twurl is making it easy. Thank you!"
        end

      end

      describe ".favorite_destroy" do

        before do
          stub_delete("favorites/destroy/25938088801.#{format}").
            to_return(:body => fixture("status.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
        end

        it "should get the correct resource" do
          @client.favorite_destroy(25938088801)
          a_delete("favorites/destroy/25938088801.#{format}").
            should have_been_made
        end

        it "should return the un-favorite status when successful" do
          status = @client.favorite_destroy(25938088801)
          status.text.should == "@noradio working on implementing #NewTwitter API methods in the twitter gem. Twurl is making it easy. Thank you!"
        end
      end
    end
  end
end
