#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe StatusMessage do
  include PeopleHelper

  before do
    @user = alice
    @aspect = @user.aspects.first
  end

  describe 'scopes' do
    describe '.where_person_is_mentioned' do
      it 'returns status messages where the given person is mentioned' do
        @bo = bob.person
        @test_string = "@{Daniel; #{@bo.diaspora_handle}} can mention people like Raph"

       FactoryGirl.create(:status_message, :text => @test_string )
       FactoryGirl.create(:status_message, :text => @test_string )
       FactoryGirl.create(:status_message)

       StatusMessage.where_person_is_mentioned(@bo).count.should == 2
      end
    end

    context "tag_streams" do
      before do
        @sm1 = FactoryGirl.create(:status_message, :text => "#hashtag" , :public => true)
        @sm2 = FactoryGirl.create(:status_message, :text => "#hashtag" )
        @sm3 = FactoryGirl.create(:status_message, :text => "hashtags are #awesome", :public => true )
        @sm4 = FactoryGirl.create(:status_message, :text => "hashtags are #awesome" )

        @tag_id = ActsAsTaggableOn::Tag.where(:name => "hashtag").first.id
      end

      describe '.tag_steam' do
        it 'returns status messages tagged with the tag' do
          tag_stream = StatusMessage.send(:tag_stream, [@tag_id])
          tag_stream.should include @sm1
          tag_stream.should include @sm2
        end
      end

      describe '.public_tag_stream' do
        it 'returns public status messages tagged with the tag' do
          StatusMessage.public_tag_stream([@tag_id]).should == [@sm1]
        end
      end

      describe '.user_tag_stream' do
        it 'returns tag stream thats owned or visibile by' do
          StatusMessage.should_receive(:owned_or_visible_by_user).with(bob).and_return(StatusMessage)
          StatusMessage.should_receive(:tag_stream).with([@tag_id])

          StatusMessage.user_tag_stream(bob, [@tag_id])
        end
      end
    end
  end

  describe ".guids_for_author" do
    it 'returns an array of the status_message guids' do
      sm1 = FactoryGirl.create(:status_message, :author => alice.person)
      sm2 = FactoryGirl.create(:status_message, :author => bob.person)
      guids = StatusMessage.guids_for_author(alice.person)
      guids.should == [sm1.guid]
    end
  end

  describe '.before_create' do
    it 'calls build_tags' do
      status = FactoryGirl.build(:status_message)
      status.should_receive(:build_tags)
      status.save
    end

    it 'calls filter_mentions' do
      status = FactoryGirl.build(:status_message)
      status.should_receive(:filter_mentions)
      status.save
    end
  end

  describe '.after_create' do
    it 'calls create_mentions' do
      status = FactoryGirl.build(:status_message, text: "text @{Test; #{alice.diaspora_handle}}")
      status.should_receive(:create_mentions).and_call_original
      status.save
    end
  end

  describe '#diaspora_handle=' do
    it 'sets #author' do
      person = FactoryGirl.create(:person)
      post = FactoryGirl.build(:status_message, :author => @user.person)
      post.diaspora_handle = person.diaspora_handle
      post.author.should == person
    end
  end

  context "emptyness" do
    it "needs either a message or at least one photo" do
      n = @user.build_post(:status_message, :text => nil)
      n.should_not be_valid

      n.text = ""
      n.should_not be_valid

      n.text = "wales"
      n.should be_valid
      n.text = nil

      photo = @user.build_post(:photo, :user_file => uploaded_photo, :to => @aspect.id)
      photo.save!

      n.photos << photo
      n.should be_valid
      n.errors.full_messages.should == []
    end

    it "doesn't check for content when author is remote (federation...)" do
      p = FactoryGirl.build(:status_message, text: nil)
      p.should be_valid
    end
  end

  it 'should be postable through the user' do
    message = "Users do things"
    status = @user.post(:status_message, :text => message, :to => @aspect.id)
    db_status = StatusMessage.find(status.id)
    db_status.text.should == message
  end

  it 'should require status messages not be more than 65535 characters long' do
    message = 'a' * (65535+1)
    status_message = FactoryGirl.build(:status_message, :text => message)
    status_message.should_not be_valid
  end

  describe 'mentions' do
    before do
      @people = [alice, bob, eve].map{|u| u.person}
      @test_string = <<-STR
@{Raphael; #{@people[0].diaspora_handle}} can mention people like Raphael @{Ilya; #{@people[1].diaspora_handle}}
can mention people like Raphaellike Raphael @{Daniel; #{@people[2].diaspora_handle}} can mention people like Raph
STR
      @sm = FactoryGirl.create(:status_message, :text => @test_string )
    end

    describe '#create_mentions' do
      it 'creates a mention for everyone mentioned in the message' do
        Diaspora::Mentionable.should_receive(:people_from_string).and_return(@people)
        @sm.mentions.delete_all
        @sm.create_mentions
        @sm.mentions(true).map{|m| m.person}.to_set.should == @people.to_set
      end

      it 'does not barf if it gets called twice' do
        @sm.create_mentions

        expect{
          @sm.create_mentions
        }.to_not raise_error
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
        @sm.mentions?(FactoryGirl.build(:person)).should be_false
      end
    end

    describe "#notify_person" do
      it 'notifies the person mentioned' do
        Notification.should_receive(:notify).with(alice, anything, anything)
        @sm.notify_person(alice.person)
      end
    end

    describe "#filter_mentions" do
      it 'calls Diaspora::Mentionable#filter_for_aspects' do
        msg = FactoryGirl.build(:status_message_in_aspect)

        msg_txt = msg.raw_message
        author_usr = msg.author.owner
        aspect_id = author_usr.aspects.first.id

        Diaspora::Mentionable.should_receive(:filter_for_aspects)
                             .with(msg_txt, author_usr, aspect_id)

        msg.send(:filter_mentions)
      end

      it "doesn't do anything when public" do
        msg = FactoryGirl.build(:status_message, public: true)
        Diaspora::Mentionable.should_not_receive(:filter_for_aspects)

        msg.send(:filter_mentions)
      end
    end
  end

  describe "#nsfw" do
    it 'returns MatchObject (true) if the post contains #nsfw (however capitalised)' do
      status  = FactoryGirl.build(:status_message, :text => "This message is #nSFw")
      status.nsfw.should be_true
    end

    it 'returns nil (false) if the post does not contain #nsfw' do
      status  = FactoryGirl.build(:status_message, :text => "This message is #sFW")
      status.nsfw.should be_false
    end
  end

  describe 'tags' do
    before do
      @object = FactoryGirl.build(:status_message)
    end
    it_should_behave_like 'it is taggable'

    it 'associates different-case tags to the same tag entry' do
      assert_equal ActsAsTaggableOn.force_lowercase, true

      msg_lc = FactoryGirl.build(:status_message, :text => '#newhere')
      msg_uc = FactoryGirl.build(:status_message, :text => '#NewHere')
      msg_cp = FactoryGirl.build(:status_message, :text => '#NEWHERE')

      msg_lc.save; msg_uc.save; msg_cp.save

      tag_array = msg_lc.tags
      expect(msg_uc.tags).to match_array(tag_array)
      expect(msg_cp.tags).to match_array(tag_array)
    end
  end

  describe "XML" do
    before do
      @message = FactoryGirl.build(:status_message, :text => "I hate WALRUSES!", :author => @user.person)
      @xml = @message.to_xml.to_s
    end
    it 'serializes the escaped, unprocessed message' do
      text = "[url](http://example.org)<script> alert('xss should be federated');</script>"
      @message.text = text
      @message.to_xml.to_s.should include Builder::XChar.encode(text)
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
        @marshalled.text.should == "I hate WALRUSES!"
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

    context 'with some photos' do
      before do
        @message.photos << FactoryGirl.build(:photo)
        @message.photos << FactoryGirl.build(:photo)
        @xml = @message.to_xml.to_s
      end

      it 'serializes the photos' do
        @xml.should include "photo"
        @xml.should include @message.photos.first.remote_photo_path
      end

      describe '.from_xml' do
        before do
          @marshalled = StatusMessage.from_xml(@xml)
        end

        it 'marshals the photos' do
          @marshalled.photos.size.should == 2
        end
      end
    end

    context 'with a location' do
      before do
        @message.location = Location.new(coordinates: "1, 2").tap(&:save)
        @xml = @message.to_xml.to_s
      end

      it 'serializes the location' do
        @xml.should include "location"
        @xml.should include "lat"
        @xml.should include "lng"
      end

      describe ".from_xml" do
        before do
          @marshalled = StatusMessage.from_xml(@xml)
        end

        it 'marshals the location' do
          @marshalled.location.should be_present
        end
      end
    end

    context 'with a poll' do
      before do
        @message.poll = FactoryGirl.create(:poll, :status_message => @message)
        @xml = @message.to_xml.to_s
      end

      it 'serializes the poll' do
        @xml.should include "poll"
        @xml.should include "question"
        @xml.should include "poll_answer"
      end

      describe ".from_xml" do
        before do
          @marshalled = StatusMessage.from_xml(@xml)
        end

        it 'marshals the poll' do
          @marshalled.poll.should be_present
        end

        it 'marshals the poll answers' do
          @marshalled.poll.poll_answers.size.should == 2
        end
      end
    end


  end

  describe '#after_dispatch' do
    before do
      @photos = [alice.build_post(:photo, :pending => true, :user_file=> File.open(photo_fixture_name)),
                 alice.build_post(:photo, :pending => true, :user_file=> File.open(photo_fixture_name))]

      @photos.each(&:save!)

      @status_message = alice.build_post(:status_message, :text => "the best pebble.")
        @status_message.photos << @photos

      @status_message.save!
      alice.add_to_streams(@status_message, alice.aspects)
    end
    it 'sets pending to false on any attached photos' do
      @status_message.after_dispatch(alice)
      @photos.all?{|p| p.reload.pending}.should be_false
    end
    it 'dispatches any attached photos' do
      alice.should_receive(:dispatch_post).twice
      @status_message.after_dispatch(alice)
    end
  end

  describe 'oembed' do
    before do
      @youtube_url = "https://www.youtube.com/watch?v=3PtFwlKfvHI"
      @message_text = "#{@youtube_url} is so cool. so is this link -> https://joindiaspora.com"
    end

    it 'should queue a GatherOembedData if it includes a link' do
      sm = FactoryGirl.build(:status_message, :text => @message_text)
      Workers::GatherOEmbedData.should_receive(:perform_async).with(instance_of(Fixnum), instance_of(String))
      sm.save
    end

    describe '#contains_oembed_url_in_text?' do
      it 'returns the oembed urls found in the raw message' do
        sm = FactoryGirl.build(:status_message, :text => @message_text)
        sm.contains_oembed_url_in_text?.should_not be_nil
        sm.oembed_url.should == @youtube_url
      end
    end
  end

  describe 'opengraph' do
    before do
      @ninegag_url = "http://9gag.com/gag/a1AMW16"
      @youtube_url = "https://www.youtube.com/watch?v=3PtFwlKfvHI"
      @message_text = "#{@ninegag_url} is so cool. so is this link -> https://joindiaspora.com"
      @oemessage_text = "#{@youtube_url} is so cool. so is this link -> https://joindiaspora.com"
    end

    it 'should queue a GatherOpenGraphData if it includes a link' do
      sm = FactoryGirl.build(:status_message, :text => @message_text)
      Workers::GatherOpenGraphData.should_receive(:perform_async).with(instance_of(Fixnum), instance_of(String))
      sm.save
    end

    describe '#contains_open_graph_url_in_text?' do
      it 'returns the opengraph urls found in the raw message' do
        sm = FactoryGirl.build(:status_message, :text => @message_text)
        sm.contains_open_graph_url_in_text?.should_not be_nil
        sm.open_graph_url.should == @ninegag_url
      end
      it 'returns nil if the link is from trusted oembed provider' do
        sm = FactoryGirl.build(:status_message, :text => @oemessage_text)
        sm.contains_open_graph_url_in_text?.should be_nil
        sm.open_graph_url.should be_nil
      end
    end
  end
end
