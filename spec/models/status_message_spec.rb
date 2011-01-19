#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe StatusMessage do

  before do
    @user = alice
    @aspect = @user.aspects.first
  end

  describe '#diaspora_handle=' do
    it 'sets #person' do
      person = Factory.create(:person)
      post = Factory.create(:status_message, :person => @user.person)
      post.diaspora_handle = person.diaspora_handle
      post.person.should == person
    end
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
    n.valid?
    n.errors.full_messages.should == []
  end

  it 'should be postable through the user' do
    message = "Users do things"
    status = @user.post(:status_message, :message => message, :to => @aspect.id)
    db_status = StatusMessage.find(status.id)
    db_status.message.should == message
  end

  it 'should require status messages to be less than 1000 characters' do
    message = ''
    1001.times do message = message +'1';end
    status = Factory.build(:status_message, :message => message)

    status.should_not be_valid

  end

  describe "XML" do
    before do
      @message = Factory.create(:status_message, :message => "I hate WALRUSES!", :person => @user.person)
      @xml = @message.to_xml.to_s
    end
    it 'serializes the message' do
      @xml.should include "<message>I hate WALRUSES!</message>"
    end

    it 'serializes the author address' do
      @xml.should include(@user.person.diaspora_handle)
    end

    describe '.from_xml' do
      before do
        @marshalled = StatusMessage.from_xml(@xml)
      end
      it 'marshals the message' do
        @marshalled.message.should == "I hate WALRUSES!"
      end
      it 'marshals the guid' do
        @marshalled.guid.should == @message.guid
      end
      it 'marshals the author' do
        @marshalled.person.should == @message.person
      end
      it 'marshals the diaspora_handle' do
        @marshalled.diaspora_handle.should == @message.diaspora_handle
      end
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
      Post.find(post.id).youtube_titles.should == {video_id => CGI::escape(expected_title)}
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
