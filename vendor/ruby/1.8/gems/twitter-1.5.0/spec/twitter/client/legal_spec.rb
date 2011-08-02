require 'helper'

describe Twitter::Client do
  Twitter::Configuration::VALID_FORMATS.each do |format|
    context ".new(:format => '#{format}')" do
      before do
        @client = Twitter::Client.new(:format => format, :consumer_key => 'CK', :consumer_secret => 'CS', :oauth_token => 'OT', :oauth_token_secret => 'OS')
      end

      describe ".tos" do

        before do
          stub_get("legal/tos.#{format}").
            to_return(:body => fixture("tos.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
        end

        it "should get the correct resource" do
          @client.tos
          a_get("legal/tos.#{format}").
            should have_been_made
        end

        it "should return Twitter's Terms of Service" do
          tos = @client.tos
          tos.split.first.should == "Terms"
        end

      end

      describe ".privacy" do

        before do
          stub_get("legal/privacy.#{format}").
            to_return(:body => fixture("privacy.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
        end

        it "should get the correct resource" do
          @client.privacy
          a_get("legal/privacy.#{format}").
            should have_been_made
        end

        it "should return Twitter's Privacy Policy" do
          privacy = @client.privacy
          privacy.split.first.should == "Twitter"
        end
      end
    end
  end
end
