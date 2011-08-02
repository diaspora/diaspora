require 'helper'

describe Twitter::Client do
  Twitter::Configuration::VALID_FORMATS.each do |format|
    context ".new(:format => '#{format}')" do
      before do
        @client = Twitter::Client.new(:format => format, :consumer_key => 'CK', :consumer_secret => 'CS', :oauth_token => 'OT', :oauth_token_secret => 'OS')
      end

      describe ".saved_searches" do

        before do
          stub_get("saved_searches.#{format}").
            to_return(:body => fixture("saved_searches.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
        end

        it "should get the correct resource" do
          @client.saved_searches
          a_get("saved_searches.#{format}").
            should have_been_made
        end

        it "should return the authenticated user's saved search queries" do
          saved_searches = @client.saved_searches
          saved_searches.should be_an Array
          saved_searches.first.name.should == "twitter"
        end

      end

      describe ".saved_search" do

        before do
          stub_get("saved_searches/show/16129012.#{format}").
            to_return(:body => fixture("saved_search.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
        end

        it "should get the correct resource" do
          @client.saved_search(16129012)
          a_get("saved_searches/show/16129012.#{format}").
            should have_been_made
        end

        it "should return the data for a saved search owned by the authenticating user specified by the given id" do
          saved_search = @client.saved_search(16129012)
          saved_search.name.should == "twitter"
        end

      end

      describe ".saved_search_create" do

        before do
          stub_post("saved_searches/create.#{format}").
            with(:body => {:query => "twitter"}).
            to_return(:body => fixture("saved_search.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
        end

        it "should get the correct resource" do
          @client.saved_search_create("twitter")
          a_post("saved_searches/create.#{format}").
            with(:body => {:query => "twitter"}).
            should have_been_made
        end

        it "should return the created saved search" do
          saved_search = @client.saved_search_create("twitter")
          saved_search.name.should == "twitter"
        end

      end

      describe ".saved_search_destroy" do

        before do
          stub_delete("saved_searches/destroy/16129012.#{format}").
            to_return(:body => fixture("saved_search.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
        end

        it "should get the correct resource" do
          @client.saved_search_destroy(16129012)
          a_delete("saved_searches/destroy/16129012.#{format}").
            should have_been_made
        end

        it "should return the deleted saved search" do
          saved_search = @client.saved_search_destroy(16129012)
          saved_search.name.should == "twitter"
        end
      end
    end
  end
end
