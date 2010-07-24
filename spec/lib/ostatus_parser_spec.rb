require File.dirname(__FILE__) + '/../spec_helper'

describe Diaspora::OStatusParser do
  it 'should be able to get the hub of an ostatus feed' do
    xml_path = File.dirname(__FILE__) + '/../fixtures/identica_feed.atom'
    xml = File.open(xml_path).read

    Diaspora::OStatusParser::find_hub(xml).should == 'http://identi.ca/main/push/hub'
  end


  describe 'subscriber info' do
    before do
      #load file
      xml_path = File.dirname(__FILE__) + '/../fixtures/ostatus_update.xml'
      @xml = File.open(xml_path).read
      @xml = Nokogiri::HTML(@xml)
    end


    it 'should parse the users service' do
      Diaspora::OStatusParser::parse_service(@xml).should == 'StatusNet'
    end

    it 'should parse the feed_url' do
      Diaspora::OStatusParser::parse_feed_url(@xml).should == 'http://identi.ca/api/statuses/user_timeline/217769.atom'
    end

    it 'should parse the avatar thumbnail' do 
      Diaspora::OStatusParser::parse_avatar_thumbnail(@xml).should == 'http://theme.status.net/0.9.3/identica/default-avatar-profile.png'
    end
    
    it 'should parse the username' do
      Diaspora::OStatusParser::parse_username(@xml).should == 'danielgrippi'
    end

    it 'should parse the profile_url' do
      Diaspora::OStatusParser::parse_profile_url(@xml).should == 'http://identi.ca/user/217769'
    end

  end

  describe 'entry' do
    before do
      #load file
      xml_path = File.dirname(__FILE__) + '/../fixtures/ostatus_update.xml'
      @xml = File.open(xml_path).read
      @xml = Nokogiri::HTML(@xml)
    end

    it 'should parse the message' do
      Diaspora::OStatusParser::parse_message(@xml).should == 'SOAP!'
    end

    it 'should parse the permalink' do
      Diaspora::OStatusParser::parse_permalink(@xml).should == 'http://identi.ca/notice/43074747'
    end

    it 'should parse published at date' do
      Diaspora::OStatusParser::parse_published_at(@xml).should == '2010-07-22T22:15:31+00:00'

    end

    it 'should parse the updated at date' do
      Diaspora::OStatusParser::parse_updated_at(@xml).should == '2010-07-22T22:15:31+00:00'
    end
  end
end