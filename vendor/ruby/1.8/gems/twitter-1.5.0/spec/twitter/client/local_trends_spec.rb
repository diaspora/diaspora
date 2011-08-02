require 'helper'

describe Twitter::Client do
  Twitter::Configuration::VALID_FORMATS.each do |format|
    context ".new(:format => '#{format}')" do
      before do
        @client = Twitter::Client.new(:format => format, :consumer_key => 'CK', :consumer_secret => 'CS', :oauth_token => 'OT', :oauth_token_secret => 'OS')
      end

      describe ".trend_locations" do

        before do
          stub_get("trends/available.#{format}").
            to_return(:body => fixture("locations.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
        end

        it "should get the correct resource" do
          @client.trend_locations
          a_get("trends/available.#{format}").
            should have_been_made
        end

        it "should return the locations that Twitter has trending topic information for" do
          locations = @client.trend_locations
          locations.should be_an Array
          locations.first.name.should == "Ireland"
        end

      end

      describe ".local_trends" do

        context "with woeid passed" do

          before do
            stub_get("trends/2487956.#{format}").
              to_return(:body => fixture("matching_trends.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
          end

          it "should get the correct resource" do
            @client.local_trends(2487956)
            a_get("trends/2487956.#{format}").
              should have_been_made
          end

          it "should return the top 10 trending topics for a specific WOEID" do
            matching_trends = @client.local_trends(2487956)
            matching_trends.should be_an Array
            matching_trends.first.should == "#sevenwordsaftersex"
          end

        end

        context "without arguments passed" do

          before do
            stub_get("trends/1.#{format}").
              to_return(:body => fixture("matching_trends.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
          end

          it "should get the correct resource" do
            @client.local_trends
            a_get("trends/1.#{format}").
              should have_been_made
          end

          it "should return the top 10 trending topics worldwide" do
            matching_trends = @client.local_trends
            matching_trends.should be_an Array
            matching_trends.first.should == "#sevenwordsaftersex"
          end
        end
      end
    end
  end
end
