#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe StatusMessage do

  before do
    @user = Factory(:user)
    @aspect = @user.aspects.create(:name => "losers")
  end

  it "should have either a message or at least one photo" do
    n = Factory.build(:status_message, :message => nil)
    n.valid?.should be_false

    n.message = ""
    n.valid?.should be_false

    n.message = "wales"
    n.valid?.should be_true
    n.message = nil

    photo = @user.build_post(:photo, :user_file => uploaded_photo, :to => @aspect.id)
    photo.save!

    n.photos << photo
    n.valid?.should be_true
  end

  it 'should be postable through the user' do
    status = @user.post(:status_message, :message => "Users do things", :to => @aspect.id)
  end

  it 'should require status messages to be less than 1000 characters' do
    message = ''
    1001.times do message = message +'1';end
    status = Factory.build(:status_message, :message => message)

    status.should_not be_valid
    
  end

  describe "XML" do
    it 'should serialize to XML' do
      message = Factory.create(:status_message, :message => "I hate WALRUSES!", :person => @user.person)
      message.to_xml.to_s.should include "<message>I hate WALRUSES!</message>"
    end

    it 'should marshal serialized XML to object' do
      xml = "<statusmessage><message>I hate WALRUSES!</message></statusmessage>"
      parsed = StatusMessage.from_xml(xml)
      parsed.message.should == "I hate WALRUSES!"
      parsed.valid?.should be_true
    end
  end

  describe 'youtube' do
    it 'should process youtube titles on the way in' do
      video_id = "ABYnqp-bxvg"
      url="http://www.youtube.com/watch?v=#{video_id}&a=GxdCwVVULXdvEBKmx_f5ywvZ0zZHHHDU&list=ML&playnext=1"
      expected_title = "UP & down & UP & down &amp;"

      mock_http = mock("http")
      Net::HTTP.stub!(:new).with('gdata.youtube.com', 80).and_return(mock_http)
      mock_http.should_receive(:get).with('/feeds/api/videos/'+video_id+'?v=2', nil).and_return(
        [nil, 'Foobar <title>'+expected_title+'</title> hallo welt <asd><dasdd><a>dsd</a>'])

      post = @user.build_post :status_message, :message => url, :to => @aspect.id
      
      post.save!
      post[:youtube_titles].should == {video_id => expected_title}
    end
  end

  describe '#public_message' do
    before do
      message = ""
      440.times{message << 'd'}
      @status_message = @user.post(:status_message, :message => message, :to => @aspect.id)
    end

    it 'truncates the message' do
      @status_message.public_message(140).length.should == 140
      @status_message.public_message(420).length.should == 420
    end

    it 'has the correct length if a url is present' do
      @status_message.public_message(140, "a_url_goes_here").length.should == 140
    end

    it 'adds the public link if present' do
      @status_message.public_message(140, "/p/#{@status_message.id}").should include "/p/#{@status_message.id}"
    end
  end
end
