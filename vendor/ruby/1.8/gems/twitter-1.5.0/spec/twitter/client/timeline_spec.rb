require 'helper'

describe Twitter::Client do
  Twitter::Configuration::VALID_FORMATS.each do |format|
    context ".new(:format => '#{format}')" do
      before do
        @client = Twitter::Client.new(:format => format, :consumer_key => 'CK', :consumer_secret => 'CS', :oauth_token => 'OT', :oauth_token_secret => 'OS')
      end

      describe ".public_timeline" do

        before do
          stub_get("statuses/public_timeline.#{format}").
            to_return(:body => fixture("statuses.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
        end

        it "should get the correct resource" do
          @client.public_timeline
          a_get("statuses/public_timeline.#{format}").
            should have_been_made
        end

        it "should return the 20 most recent statuses, including retweets if they exist, from non-protected users" do
          statuses = @client.public_timeline
          statuses.should be_an Array
          statuses.first.text.should == "Ruby is the best programming language for hiding the ugly bits."
        end

      end

      describe ".home_timeline" do

        before do
          stub_get("statuses/home_timeline.#{format}").
            to_return(:body => fixture("statuses.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
        end

        it "should get the correct resource" do
          @client.home_timeline
          a_get("statuses/home_timeline.#{format}").
            should have_been_made
        end

        it "should return the 20 most recent statuses, including retweets if they exist, posted by the authenticating user and the user's they follow" do
          statuses = @client.home_timeline
          statuses.should be_an Array
          statuses.first.text.should == "Ruby is the best programming language for hiding the ugly bits."
        end

      end

      describe ".friends_timeline" do

        before do
          stub_get("statuses/friends_timeline.#{format}").
            to_return(:body => fixture("statuses.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
        end

        it "should get the 20 most recent statuses posted by the authenticating user and the user's they follow" do
          @client.friends_timeline
          a_get("statuses/friends_timeline.#{format}").
            should have_been_made
        end

        it "should return a timeline" do
          statuses = @client.friends_timeline
          statuses.should be_an Array
          statuses.first.text.should == "Ruby is the best programming language for hiding the ugly bits."
        end

      end

      describe ".user_timeline" do

        context "with screen name passed" do

          before do
            stub_get("statuses/user_timeline.#{format}").
              with(:query => {:screen_name => "sferik"}).
              to_return(:body => fixture("statuses.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
          end

          it "should get the correct resource" do
            @client.user_timeline("sferik")
            a_get("statuses/user_timeline.#{format}").
              with(:query => {:screen_name => "sferik"}).
              should have_been_made
          end

          it "should return the 20 most recent statuses posted by the user specified by screen name or user id" do
            statuses = @client.user_timeline("sferik")
            statuses.should be_an Array
            statuses.first.text.should == "Ruby is the best programming language for hiding the ugly bits."
          end

        end

        context "without screen name passed" do

          before do
            @client.stub!(:get_screen_name).and_return('sferik')
            stub_get("statuses/user_timeline.#{format}").
              with(:query => {:screen_name => "sferik"}).
              to_return(:body => fixture("statuses.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
          end

          it "should get the correct resource" do
            @client.user_timeline()
            a_get("statuses/user_timeline.#{format}").
              with(:query => {:screen_name => "sferik"}).
              should have_been_made
          end

        end

      end

      describe ".mentions" do

        before do
          stub_get("statuses/mentions.#{format}").
            to_return(:body => fixture("statuses.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
        end

        it "should get the correct resource" do
          @client.mentions
          a_get("statuses/mentions.#{format}").
            should have_been_made
        end

        it "should return the 20 most recent mentions (status containing @username) for the authenticating user" do
          statuses = @client.mentions
          statuses.should be_an Array
          statuses.first.text.should == "Ruby is the best programming language for hiding the ugly bits."
        end

      end

      describe ".retweeted_by_me" do

        before do
          stub_get("statuses/retweeted_by_me.#{format}").
            to_return(:body => fixture("statuses.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
        end

        it "should get the correct resource" do
          @client.retweeted_by_me
          a_get("statuses/retweeted_by_me.#{format}").
            should have_been_made
        end

        it "should return the 20 most recent retweets posted by the authenticating user" do
          statuses = @client.retweeted_by_me
          statuses.should be_an Array
          statuses.first.text.should == "Ruby is the best programming language for hiding the ugly bits."
        end

      end

      describe ".retweeted_to_me" do

        before do
          stub_get("statuses/retweeted_to_me.#{format}").
            to_return(:body => fixture("statuses.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
        end

        it "should get the correct resource" do
          @client.retweeted_to_me
          a_get("statuses/retweeted_to_me.#{format}").
            should have_been_made
        end

        it "should return the 20 most recent retweets posted by users the authenticating user follow" do
          statuses = @client.retweeted_to_me
          statuses.should be_an Array
          statuses.first.text.should == "Ruby is the best programming language for hiding the ugly bits."
        end

      end

      describe ".retweets_of_me" do

        before do
          stub_get("statuses/retweets_of_me.#{format}").
            to_return(:body => fixture("statuses.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
        end

        it "should get the correct resource" do
          @client.retweets_of_me
          a_get("statuses/retweets_of_me.#{format}").
            should have_been_made
        end

        it "should return the 20 most recent tweets of the authenticated user that have been retweeted by others" do
          statuses = @client.retweets_of_me
          statuses.should be_an Array
          statuses.first.text.should == "Ruby is the best programming language for hiding the ugly bits."
        end

      end

    end
  end
end
