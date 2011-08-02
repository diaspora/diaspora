require 'helper'

describe Twitter::Client do
  Twitter::Configuration::VALID_FORMATS.each do |format|
    context ".new(:format => '#{format}')" do
      before do
        @client = Twitter::Client.new(:format => format, :consumer_key => 'CK', :consumer_secret => 'CS', :oauth_token => 'OT', :oauth_token_secret => 'OS')
      end

      describe ".user" do

        context "with screen name passed" do

            before do
              stub_get("users/show.#{format}").
                with(:query => {:screen_name => "sferik"}).
                to_return(:body => fixture("sferik.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
            end

            it "should get the correct resource" do
              @client.user("sferik")
              a_get("users/show.#{format}").
                with(:query => {:screen_name => "sferik"}).
                should have_been_made
            end

            it "should return extended information of a given user" do
              user = @client.user("sferik")
              user.name.should == "Erik Michaels-Ober"
            end

        end

        context "with screen name including '@' passed" do

          before do
            stub_get("users/show.#{format}").
              with(:query => {:screen_name => "@sferik"}).
              to_return(:body => fixture("sferik.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
          end

          it "should get the correct resource" do
            @client.user("@sferik")
            a_get("users/show.#{format}").
              with(:query => {:screen_name => "@sferik"}).
              should have_been_made
          end

        end

        context "with numeric screen name passed" do

          before do
            stub_get("users/show.#{format}").
              with(:query => {:screen_name => "0"}).
              to_return(:body => fixture("sferik.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
          end

          it "should get the correct resource" do
            @client.user("0")
            a_get("users/show.#{format}").
              with(:query => {:screen_name => "0"}).
              should have_been_made
          end

        end

        context "with user ID passed" do

          before do
            stub_get("users/show.#{format}").
              with(:query => {:user_id => "7505382"}).
              to_return(:body => fixture("sferik.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
          end

          it "should get the correct resource" do
            @client.user(7505382)
            a_get("users/show.#{format}").
              with(:query => {:user_id => "7505382"}).
              should have_been_made
          end

        end

        context "without screen name or user ID passed" do

          before do
            @client.stub!(:get_screen_name).and_return('sferik')
            stub_get("users/show.#{format}").
              with(:query => {:screen_name => "sferik"}).
              to_return(:body => fixture("sferik.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
          end

          it "should get the correct resource" do
            @client.user()
            a_get("users/show.#{format}").
              with(:query => {:screen_name => "sferik"}).
              should have_been_made
          end

        end

      end

      describe ".users" do

        context "with screen names passed" do

          before do
            stub_get("users/lookup.#{format}").
              with(:query => {:screen_name => "sferik,pengwynn"}).
              to_return(:body => fixture("users.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
          end

          it "should get the correct resource" do
            @client.users("sferik", "pengwynn")
            a_get("users/lookup.#{format}").
              with(:query => {:screen_name => "sferik,pengwynn"}).
              should have_been_made
          end

          it "should return up to 100 users worth of extended information" do
            users = @client.users("sferik", "pengwynn")
            users.should be_an Array
            users.first.name.should == "Erik Michaels-Ober"
          end

        end

        context "with numeric screen names passed" do

          before do
            stub_get("users/lookup.#{format}").
              with(:query => {:screen_name => "0,311"}).
              to_return(:body => fixture("users.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
          end

          it "should get the correct resource" do
            @client.users("0", "311")
            a_get("users/lookup.#{format}").
              with(:query => {:screen_name => "0,311"}).
              should have_been_made
          end

        end

        context "with user IDs passed" do

          before do
            stub_get("users/lookup.#{format}").
              with(:query => {:user_id => "7505382,14100886"}).
              to_return(:body => fixture("users.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
          end

          it "should get the correct resource" do
            @client.users(7505382, 14100886)
            a_get("users/lookup.#{format}").
              with(:query => {:user_id => "7505382,14100886"}).
              should have_been_made
          end

        end

        context "with both screen names and user IDs passed" do

          before do
            stub_get("users/lookup.#{format}").
              with(:query => {:screen_name => "sferik", :user_id => "14100886"}).
              to_return(:body => fixture("users.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
          end

          it "should get the correct resource" do
            @client.users("sferik", 14100886)
            a_get("users/lookup.#{format}").
              with(:query => {:screen_name => "sferik", :user_id => "14100886"}).
              should have_been_made
          end

        end

      end

      describe ".user_search" do

        before do
          stub_get("users/search.#{format}").
            with(:query => {:q => "Erik Michaels-Ober"}).
            to_return(:body => fixture("user_search.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
        end

        it "should get the correct resource" do
          @client.user_search("Erik Michaels-Ober")
          a_get("users/search.#{format}").
            with(:query => {:q => "Erik Michaels-Ober"}).
            should have_been_made
        end

        it "should return an array of user search results" do
          user_search = @client.user_search("Erik Michaels-Ober")
          user_search.should be_an Array
          user_search.first.name.should == "Erik Michaels-Ober"
        end

      end

      describe ".suggestions" do

        context "with a category slug passed" do

          before do
            stub_get("users/suggestions/art-design.#{format}").
              to_return(:body => fixture("category.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
          end

          it "should get the correct resource" do
            @client.suggestions("art-design")
            a_get("users/suggestions/art-design.#{format}").
              should have_been_made
          end

          it "should return the users in a given category of the Twitter suggested user list" do
            category = @client.suggestions("art-design")
            category.name.should == "Art & Design"
          end

        end

        context "without arguments passed" do

          before do
            stub_get("users/suggestions.#{format}").
              to_return(:body => fixture("suggestions.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
          end

          it "should get the correct resource" do
            @client.suggestions
            a_get("users/suggestions.#{format}").
              should have_been_made
          end

          it "should return the list of suggested user categories" do
            suggestions = @client.suggestions
            suggestions.should be_an Array
            suggestions.first.name.should == "Art & Design"
          end

        end

      end

      describe ".profile_image" do

        context "with screen name passed" do

          before do
            stub_get("users/profile_image/sferik.#{format}").
              to_return(fixture("profile_image.text"))
          end

          it "should redirect to the correct resource" do
            profile_image = @client.profile_image("sferik")
            a_get("users/profile_image/sferik.#{format}").
              with(:status => 302).
              should have_been_made
            profile_image.should == "http://a0.twimg.com/profile_images/323331048/me_normal.jpg"
          end

        end

        context "without screen name passed" do

          before do
            @client.stub!(:get_screen_name).and_return('sferik')
            stub_get("users/profile_image/sferik.#{format}").
              to_return(fixture("profile_image.text"))
          end

          it "should redirect to the correct resource" do
            profile_image = @client.profile_image()
            a_get("users/profile_image/sferik.#{format}").
              with(:status => 302).
              should have_been_made
            profile_image.should == "http://a0.twimg.com/profile_images/323331048/me_normal.jpg"
          end

        end

      end

      describe ".friends" do

        context "with a screen name passed" do

          before do
            stub_get("statuses/friends.#{format}").
              with(:query => {:screen_name => "sferik", :cursor => "-1"}).
              to_return(:body => fixture("friends.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
          end

          it "should get the correct resource" do
            @client.friends("sferik")
            a_get("statuses/friends.#{format}").
              with(:query => {:screen_name => "sferik", :cursor => "-1"}).
              should have_been_made
          end

          it "should return a user's friends, each with current status inline" do
            friends = @client.friends("sferik")
            friends.users.should be_an Array
            friends.users.first.name.should == "Tim O'Reilly"
          end

        end

        context "without arguments passed" do

          before do
            stub_get("statuses/friends.#{format}").
              with(:query => {:cursor => "-1"}).
              to_return(:body => fixture("friends.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
          end

          it "should get the correct resource" do
            @client.friends
            a_get("statuses/friends.#{format}").
              with(:query => {:cursor => "-1"}).
              should have_been_made
          end

          it "should return a user's friends, each with current status inline" do
            friends = @client.friends
            friends.users.should be_an Array
            friends.users.first.name.should == "Tim O'Reilly"
          end

        end

      end

      describe ".followers" do

        context "with a screen name passed" do

          before do
            stub_get("statuses/followers.#{format}").
              with(:query => {:screen_name => "sferik", :cursor => "-1"}).
              to_return(:body => fixture("followers.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
          end

          it "should get the correct resource" do
            @client.followers("sferik")
            a_get("statuses/followers.#{format}").
              with(:query => {:screen_name => "sferik", :cursor => "-1"}).
              should have_been_made
          end

          it "should return a user's followers, each with current status inline" do
            followers = @client.followers("sferik")
            followers.users.should be_an Array
            followers.users.first.name.should == "Joel Mahoney"
          end

        end

        context "without arguments passed" do

          before do
            stub_get("statuses/followers.#{format}").
              with(:query => {:cursor => "-1"}).
              to_return(:body => fixture("followers.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
          end

          it "should get the correct resource" do
            @client.followers
            a_get("statuses/followers.#{format}").
              with(:query => {:cursor => "-1"}).
              should have_been_made
          end

          it "should return a user's followers, each with current status inline" do
            followers = @client.followers
            followers.users.should be_an Array
            followers.users.first.name.should == "Joel Mahoney"
          end
        end
      end
    end
  end
end
