#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'


describe StatusMessage do
  include ActionView::Helpers::UrlHelper
  include Rails.application.routes.url_helpers
  def controller
    mock()
  end

  before do
    @user = alice
    @aspect = @user.aspects.first
  end

  describe '.before_create' do
    it 'calls create_mentions' do
      status = Factory.build(:status_message)
      status.should_receive(:create_mentions)
      status.save
    end
    it 'calls build_tags' do
      status = Factory.build(:status_message)
      status.should_receive(:build_tags)
      status.save
    end
  end

  describe '#diaspora_handle=' do
    it 'sets #author' do
      person = Factory.create(:person)
      post = Factory.create(:status_message, :author => @user.person)
      post.diaspora_handle = person.diaspora_handle
      post.author.should == person
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
    n.valid?.should be_true
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

  describe 'mentions' do
    before do
      @people = [alice, bob, eve].map{|u| u.person}
      @test_string = <<-STR
@{Raphael; #{@people[0].diaspora_handle}} can mention people like Raphael @{Ilya; #{@people[1].diaspora_handle}}
can mention people like Raphaellike Raphael @{Daniel; #{@people[2].diaspora_handle}} can mention people like Raph
STR
      @sm = Factory.create(:status_message, :message => @test_string )
    end

    describe '#format_mentions' do
      it 'adds the links in the formated message text' do
        @sm.format_mentions(@sm.raw_message).should == <<-STR
#{link_to('@' << @people[0].name, person_path(@people[0]), :class => 'mention')} can mention people like Raphael #{link_to('@' << @people[1].name, person_path(@people[1]), :class => 'mention')}
can mention people like Raphaellike Raphael #{link_to('@' << @people[2].name, person_path(@people[2]), :class => 'mention')} can mention people like Raph
STR
      end

      context 'with :plain_text option' do
        it 'removes the mention syntax and displays the unformatted name' do
          status  = Factory(:status_message, :message => "@{Barack Obama; barak@joindiaspora.com } is so cool @{Barack Obama; barak@joindiaspora.com } ")
          status.format_mentions(status.raw_message, :plain_text => true).should == 'Barack Obama is so cool Barack Obama '
        end
      end

      it 'leaves the name of people that cannot be found' do
        @sm.stub(:mentioned_people).and_return([])
        @sm.format_mentions(@sm.raw_message).should == <<-STR
Raphael can mention people like Raphael Ilya
can mention people like Raphaellike Raphael Daniel can mention people like Raph
STR
      end
      it 'escapes the link title' do
        p = @people[0].profile
        p.first_name="</a><script>alert('h')</script>"
["a", "b", "A", "C"]\
.inject(Hash.new){ |h,element| h[element.downcase] = element  unless h[element.downcase]  ; h }\
.values
        p.save!

        @sm.format_mentions(@sm.raw_message).should_not include(@people[0].profile.first_name)
      end
    end
    describe '#formatted_message' do
      it 'escapes the message' do
        xss = "</a> <script> alert('hey'); </script>"
        @sm.message << xss

        @sm.formatted_message.should_not include xss
      end
      it 'is html_safe' do
        @sm.formatted_message.html_safe?.should be_true
      end
    end

    describe '#mentioned_people_from_string' do
      it 'extracts the mentioned people from the message' do
        @sm.mentioned_people_from_string.to_set.should == @people.to_set
      end
    end
    describe '#create_mentions' do

      it 'creates a mention for everyone mentioned in the message' do
        @sm.should_receive(:mentioned_people_from_string).and_return(@people)
        @sm.mentions.delete_all
        @sm.create_mentions
        @sm.mentions(true).map{|m| m.person}.to_set.should == @people.to_set
      end
    end
    describe '#mentioned_people' do
      it 'calls create_mentions if there are no mentions in the db' do
        @sm.mentions.delete_all
        @sm.should_receive(:create_mentions)
        @sm.mentioned_people
      end
      it 'returns the mentioned people' do
        @sm.mentions.delete_all
        @sm.mentioned_people.to_set.should == @people.to_set
      end
      it 'does not call create_mentions if there are mentions in the db' do
        @sm.should_not_receive(:create_mentions)
        @sm.mentioned_people
      end
    end

    describe "#mentions?" do
      it 'returns true if the person was mentioned' do
        @sm.mentions?(@people[0]).should be_true
      end

      it 'returns false if the person was not mentioned' do
        @sm.mentions?(Factory.create(:person)).should be_false
      end
    end

    describe "#notify_person" do
      it 'notifies the person mentioned' do
        Notification.should_receive(:notify).with(alice, anything, anything)
        @sm.notify_person(alice.person)
      end
    end
  end
  describe 'tags' do
    before do
      @sm = Factory.build(:status_message)
    end
    describe '#format_tags' do
      before do
        @str = '#what #hey'
        @sm.message = @str
        @sm.build_tags
        @sm.save
        @sm.reload
      end
      it 'links the tag to /p' do
        link = link_to('#what', posts_path(:tag => 'what'), :class => 'tag')
        @sm.format_tags(@str).should include(link)
      end
      it 'responds to plain_text' do
        @sm.format_tags(@str, :plain_text => true).should == @str
      end
    end
    describe '#build_tags' do
      it 'builds the tags' do
        @sm.message = '#what'
        @sm.build_tags
        @sm.tag_list.should == ['what']
        lambda {
          @sm.save
        }.should change{@sm.tags.count}.by(1)
      end
    end
    describe '#tag_strings' do
      it 'returns a string for every #thing' do
        str = '#what #hey #that"smybike. #@hey ##boo # #THATWASMYBIKE #hey#there #135440we #abc/23 ###'
        arr = ['what', 'hey', 'that', 'THATWASMYBIKE', '135440we', 'abc']

        @sm.message = str
        @sm.tag_strings.should =~ arr
      end
      it 'returns no duplicates' do
        str = '#what #what #what #whaaaaaaaaaat'
        arr = ['what','whaaaaaaaaaat']

        @sm.message = str
        @sm.tag_strings.should =~ arr
      end
      it 'is case insensitive' do
        str = '#what #wHaT #WHAT'
        arr = ['what']

        @sm.message = str
        @sm.tag_strings.should =~ arr
      end
    end
  end
  describe "XML" do
    before do
      @message = Factory.create(:status_message, :message => "I hate WALRUSES!", :author => @user.person)
      @xml = @message.to_xml.to_s
    end
    it 'serializes the unescaped, unprocessed message' do
      @message.message = "<script> alert('xss should be federated');</script>"
      @message.to_xml.to_s.should include @message.message
    end
    it 'serializes the message' do
      @xml.should include "<raw_message>I hate WALRUSES!</raw_message>"
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
        @marshalled.author.should == @message.author
      end
      it 'marshals the diaspora_handle' do
        @marshalled.diaspora_handle.should == @message.diaspora_handle
      end
    end


    describe '#to_activity' do
      it 'should render a string' do
        @message.to_activity.should_not be_blank
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
end
