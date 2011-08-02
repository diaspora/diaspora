require 'helper'

describe Twitter::Search do

  it "should connect using the search_endpoint configuration" do
    search = Twitter::Search.new
    endpoint = URI.parse(search.api_endpoint)
    connection = search.send(:connection).build_url(nil).to_s
    connection.should == endpoint.to_s
  end

  context "with module configuration" do

    before do
      @keys = Twitter::Configuration::VALID_OPTIONS_KEYS
      Twitter.configure do |config|
        @keys.each do |key|
          config.send("#{key}=", key)
        end
      end
    end

    after do
      Twitter.reset
    end

    it "should inherit module configuration" do
      client = Twitter::Search.new
      @keys.each do |key|
        client.send(key).should == key
      end
    end

    context "with class configuration" do

      before do
        @configuration = {
          :consumer_key => 'CK',
          :consumer_secret => 'CS',
          :oauth_token => 'OT',
          :oauth_token_secret => 'OS',
          :adapter => :typhoeus,
          :endpoint => 'http://tumblr.com/',
          :gateway => 'apigee-32234.apigee.com',
          :format => :xml,
          :proxy => 'http://erik:sekret@proxy.example.com:8080',
          :search_endpoint => 'http://google.com/',
          :user_agent => 'Custom User Agent',
        }
      end

      context "during initialization"

        it "should override module configuration" do
          client = Twitter::Search.new(@configuration)
          @keys.each do |key|
            client.send(key).should == @configuration[key]
          end
        end

      context "after initilization" do

        it "should override module configuration after initialization" do
          client = Twitter::Search.new
          @configuration.each do |key, value|
            client.send("#{key}=", value)
          end
          @keys.each do |key|
            client.send(key).should == @configuration[key]
          end
        end

      end

    end

  end

  context ".new" do

    before do
      @client = Twitter::Search.new(:consumer_key => 'CK', :consumer_secret => 'CS', :oauth_token => 'OT', :oauth_token_secret => 'OS', :endpoint => 'https://search.twitter.com/')
    end

    describe ".containing" do

      it "should set the query to include term" do
        @client.containing('twitter').query[:q].should include 'twitter'
      end

    end

    describe ".not_containing" do

      it "should set the query not to include term" do
        @client.not_containing('twitter').query[:q].should include '-twitter'
      end

    end

    describe ".language" do

      it "should set the language to the query" do
        @client.language('en').query[:lang].should == 'en'
      end

    end

    describe ".locale" do

      it "should set the locale to the query" do
        @client.locale('ja').query[:locale].should == 'ja'
      end

    end

    describe ".from" do

      it "should set the query to include statuses from the specified person" do
        @client.from('sferik').query[:q].should include 'from:sferik'
      end

    end

    describe ".not_from" do

      it "should set the query not to include statuses from the specified person" do
        @client.not_from('sferik').query[:q].should include '-from:sferik'
      end

      it "should exclude multiple users" do
        query = @client.not_from('sferik').not_from('pengwynn').query[:q]
        query.should include '-from:sferik'
        query.should include '-from:pengwynn'

      end

    end

    describe ".to" do

      it "should set the query to include statuses to the specified person" do
        @client.to('sferik').query[:q].should include 'to:sferik'
      end

    end

    describe ".not_to" do

      it "should set the query not to include statuses to the specified person" do
        @client.not_to('sferik').query[:q].should include '-to:sferik'
      end

    end

    describe ".mentioning" do

      it "should set the query to include mentions" do
        @client.mentioning('sferik').query[:q].should include '@sferik'
      end

    end

    describe ".not_mentioning" do

      it "should set the query not to include mentions" do
        @client.not_mentioning('sferik').query[:q].should include '-@sferik'
      end

    end

    describe ".filter" do

      it "should set the query to include filter" do
        @client.filter('links').query[:q].should include 'filter:links'
      end

    end

    describe ".retweets" do

      it "should set the query to include retweets" do
        @client.retweets.query[:q].should include 'rt'
      end

    end

    describe ".no_retweets" do

      it "should set the query not to include retweets" do
        @client.no_retweets.query[:q].should include '-rt'
      end

    end

    describe ".hashtag" do

      it "should set the query to include hashtag" do
        @client.hashtag('twitter').query[:q].should include '#twitter'
      end

    end

    describe ".excluding_hashtag" do

      it "should set the query not to include hashtag" do
        @client.excluding_hashtag('twitter').query[:q].should include '-#twitter'
      end

    end

    describe ".phrase" do

      it "should set the phrase" do
        @client.phrase('peanut butter').query[:phrase].should == 'peanut butter'
      end

    end

    describe ".result_type" do

      it "should set the result type" do
        @client.result_type('popular').query[:result_type].should == 'popular'
      end

    end

    describe ".source" do

      it "should set the source" do
        @client.source("Hibari").query[:q].should include 'source:Hibari'
      end

    end

    describe ".since_id" do

      it "should set the since id" do
        @client.since_id(1).query[:since_id].should == 1
      end

    end

    describe ".max_id" do

      it "should set the max id" do
        @client.max_id(1).query[:max_id].should == 1
      end

    end

    describe ".since_date" do

      it "should set the since date" do
        @client.since_date('2010-10-10').query[:since].should == '2010-10-10'
      end

    end

    describe ".until_date" do

      it "should set the until date" do
        @client.until_date('2010-10-10').query[:until].should == '2010-10-10'
      end

    end

    describe ".positive" do

      it "should set the query to include ':)'" do
        @client.positive.query[:tude].should include ':)'
      end

    end

    describe ".negative" do

      it "should set the query to include ':('" do
        @client.negative.query[:tude].should include ':('
      end

    end

    describe ".question" do

      it "should set the query to include '?'" do
        @client.question.query[:tude].should include '?'
      end

    end

    describe ".geocode" do

      it "should set the geocode" do
        @client.geocode(37.781157, -122.398720, '1mi').query[:geocode].should == '37.781157,-122.39872,1mi'
      end

    end

    describe ".place" do

      it "should set the place" do
        @client.place("5a110d312052166f").query[:q].should include 'place:5a110d312052166f'
      end

    end

    describe ".per_page" do

      it "should set the number of results per page" do
        @client.per_page(25).query[:rpp].should == 25
      end

    end

    describe ".page" do

      it "should set the page number" do
        @client.page(20).query[:page].should == 20
      end

    end

    describe ".next_page?" do

      before do
        stub_request(:get, "https://search.twitter.com/search.json").
          with(:query => {:q => "twitter"}).
          to_return(:body => fixture("search.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        @client.containing('twitter')
      end

      it "should get the correct resource" do
        @client.next_page?
        a_request(:get, "https://search.twitter.com/search.json").
          with(:query => {:q => "twitter"}).
          should have_been_made
      end

      it "should be true if there's another page" do
        next_page = @client.next_page?
        next_page.should be_true
      end

    end

    describe ".fetch_next_page" do

      before do
        stub_request(:get, "https://search.twitter.com/search.json").
          with(:query => {:q => "twitter"}).
          to_return(:body => fixture("search.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        stub_request(:get, "https://search.twitter.com/search.json").
          with(:query => {:q => "twitter", :page => "2", :max_id => "28857935752"}).
          to_return(:body => fixture("search.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        @client.containing('twitter')
      end

      it "should get the correct resource" do
        @client.fetch_next_page
        a_request(:get, "https://search.twitter.com/search.json").
          with(:query => {:q => "twitter"}).
          should have_been_made
        a_request(:get, "https://search.twitter.com/search.json").
          with(:query => {:q => "twitter", :page => "2", :max_id => "28857935752"}).
          should have_been_made
      end

    end

    describe ".fetch" do

      before do
        stub_request(:get, "https://search.twitter.com/search.json").
          with(:query => {:q => "twitter"}).
          to_return(:body => fixture("search.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end

      it "should get the correct resource" do
        @client.containing('twitter').fetch
        a_request(:get, "https://search.twitter.com/search.json").
          with(:query => {:q => "twitter"}).
          should have_been_made
      end

    end

    describe ".each" do

      before do
        stub_request(:get, "https://search.twitter.com/search.json").
          with(:query => {:q => "twitter"}).
          to_return(:body => fixture("search.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end

      it "should iterate over results" do
        @client.containing('twitter').each{|result| result.should be}
        a_request(:get, "https://search.twitter.com/search.json").
          with(:query => {:q => "twitter"}).
          should have_been_made
      end

      it "should iterate over results multiple times in a row" do
        @client.containing('twitter').each{|result| result.should be}
        @client.containing('twitter').each{|result| result.should be}
        a_request(:get, "https://search.twitter.com/search.json").
          with(:query => {:q => "twitter"}).
          should have_been_made
      end
    end
  end
end
