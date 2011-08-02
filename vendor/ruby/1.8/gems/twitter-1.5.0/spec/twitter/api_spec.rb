require 'helper'

describe Twitter::API do
  before do
    @keys = Twitter::Configuration::VALID_OPTIONS_KEYS
  end

  context "with module configuration" do

    before do
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
      api = Twitter::API.new
      @keys.each do |key|
        api.send(key).should == key
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
          :gateway => 'apigee-1111.apigee.com',
          :format => :xml,
          :proxy => 'http://erik:sekret@proxy.example.com:8080',
          :search_endpoint => 'http://google.com/',
          :user_agent => 'Custom User Agent',
        }
      end

      context "during initialization"

        it "should override module configuration" do
          api = Twitter::API.new(@configuration)
          @keys.each do |key|
            api.send(key).should == @configuration[key]
          end
        end

      context "after initilization" do

        it "should override module configuration after initialization" do
          api = Twitter::API.new
          @configuration.each do |key, value|
            api.send("#{key}=", value)
          end
          @keys.each do |key|
            api.send(key).should == @configuration[key]
          end
        end
      end
    end
  end
end
