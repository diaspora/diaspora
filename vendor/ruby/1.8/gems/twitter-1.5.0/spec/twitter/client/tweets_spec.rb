require 'helper'

describe Twitter::Client do
  Twitter::Configuration::VALID_FORMATS.each do |format|
    context ".new(:format => '#{format}')" do
      before do
        @client = Twitter::Client.new(:format => format, :consumer_key => 'CK', :consumer_secret => 'CS', :oauth_token => 'OT', :oauth_token_secret => 'OS')
      end

      describe ".status" do

        before do
          stub_get("statuses/show/25938088801.#{format}").
            to_return(:body => fixture("status.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
        end

        it "should get the correct resource" do
          @client.status(25938088801)
          a_get("statuses/show/25938088801.#{format}").
            should have_been_made
        end

        it "should return a single status" do
          status = @client.status(25938088801)
          status.text.should == "@noradio working on implementing #NewTwitter API methods in the twitter gem. Twurl is making it easy. Thank you!"
        end

      end

      describe ".update" do

        before do
          stub_post("statuses/update.#{format}").
            with(:body => {:status => "@noradio working on implementing #NewTwitter API methods in the twitter gem. Twurl is making it easy. Thank you!"}).
            to_return(:body => fixture("status.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
        end

        it "should get the correct resource" do
          @client.update("@noradio working on implementing #NewTwitter API methods in the twitter gem. Twurl is making it easy. Thank you!")
          a_post("statuses/update.#{format}").
            with(:body => {:status => "@noradio working on implementing #NewTwitter API methods in the twitter gem. Twurl is making it easy. Thank you!"}).
            should have_been_made
        end

        it "should return a single status" do
          status = @client.update("@noradio working on implementing #NewTwitter API methods in the twitter gem. Twurl is making it easy. Thank you!")
          status.text.should == "@noradio working on implementing #NewTwitter API methods in the twitter gem. Twurl is making it easy. Thank you!"
        end

      end

      describe ".status_destroy" do

        before do
          stub_delete("statuses/destroy/25938088801.#{format}").
            to_return(:body => fixture("status.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
        end

        it "should get the correct resource" do
          @client.status_destroy(25938088801)
          a_delete("statuses/destroy/25938088801.#{format}").
            should have_been_made
        end

        it "should return a single status" do
          status = @client.status_destroy(25938088801)
          status.text.should == "@noradio working on implementing #NewTwitter API methods in the twitter gem. Twurl is making it easy. Thank you!"
        end

      end

      describe ".retweet" do

        before do
          stub_post("statuses/retweet/28561922516.#{format}").
            to_return(:body => fixture("retweet.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
        end

        it "should get the correct resource" do
          @client.retweet(28561922516)
          a_post("statuses/retweet/28561922516.#{format}").
            should have_been_made
        end

        it "should return the original tweet with retweet details embedded" do
          status = @client.retweet(28561922516)
          status.retweeted_status.text.should == "As for the Series, I'm for the Giants. Fuck Texas, fuck Nolan Ryan, fuck George Bush."
        end

      end

      describe ".retweets" do

        before do
          stub_get("statuses/retweets/28561922516.#{format}").
            to_return(:body => fixture("retweets.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
        end

        it "should get the correct resource" do
          @client.retweets(28561922516)
          a_get("statuses/retweets/28561922516.#{format}").
            should have_been_made
        end

        it "should return up to 100 of the first retweets of a given tweet" do
          statuses = @client.retweets(28561922516)
          statuses.should be_an Array
          statuses.first.text.should == "RT @gruber: As for the Series, I'm for the Giants. Fuck Texas, fuck Nolan Ryan, fuck George Bush."
        end

      end

      describe ".retweeters_of" do

        before do
          stub_get("statuses/27467028175/retweeted_by.#{format}").
            to_return(:body => fixture("retweeters_of.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
        end

        it "should get the correct resource" do
          @client.retweeters_of(27467028175)
          a_get("statuses/27467028175/retweeted_by.#{format}").
            should have_been_made
        end

        it "should return " do
          users = @client.retweeters_of(27467028175)
          users.should be_an Array
          users.first.name.should == "Dave W Baldwin"
        end
      end
    end
  end
end
