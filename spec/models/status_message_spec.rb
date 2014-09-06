#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe StatusMessage, :type => :model do
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

       expect(StatusMessage.where_person_is_mentioned(@bo).count).to eq(2)
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
          expect(tag_stream).to include @sm1
          expect(tag_stream).to include @sm2
        end
      end

      describe '.public_tag_stream' do
        it 'returns public status messages tagged with the tag' do
          expect(StatusMessage.public_tag_stream([@tag_id])).to eq([@sm1])
        end
      end

      describe '.user_tag_stream' do
        it 'returns tag stream thats owned or visible by' do
          relation = double
          expect(StatusMessage).to receive(:owned_or_visible_by_user).with(bob).and_return(relation)
          expect(relation).to receive(:tag_stream).with([@tag_id])

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
      expect(guids).to eq([sm1.guid])
    end
  end

  describe '.before_create' do
    it 'calls build_tags' do
      status = FactoryGirl.build(:status_message)
      expect(status).to receive(:build_tags)
      status.save
    end

    it 'calls filter_mentions' do
      status = FactoryGirl.build(:status_message)
      expect(status).to receive(:filter_mentions)
      status.save
    end
  end

  describe '.after_create' do
    it 'calls create_mentions' do
      status = FactoryGirl.build(:status_message, text: "text @{Test; #{alice.diaspora_handle}}")
      expect(status).to receive(:create_mentions).and_call_original
      status.save
    end
  end

  describe '#diaspora_handle=' do
    it 'sets #author' do
      person = FactoryGirl.create(:person)
      post = FactoryGirl.build(:status_message, :author => @user.person)
      post.diaspora_handle = person.diaspora_handle
      expect(post.author).to eq(person)
    end
  end

  context "emptyness" do
    it "needs either a message or at least one photo" do
      n = @user.build_post(:status_message, :text => nil)
      expect(n).not_to be_valid

      n.text = ""
      expect(n).not_to be_valid

      n.text = "wales"
      expect(n).to be_valid
      n.text = nil

      photo = @user.build_post(:photo, :user_file => uploaded_photo, :to => @aspect.id)
      photo.save!

      n.photos << photo
      expect(n).to be_valid
      expect(n.errors.full_messages).to eq([])
    end

    it "doesn't check for content when author is remote (federation...)" do
      p = FactoryGirl.build(:status_message, text: nil)
      expect(p).to be_valid
    end
  end

  it 'should be postable through the user' do
    message = "Users do things"
    status = @user.post(:status_message, :text => message, :to => @aspect.id)
    db_status = StatusMessage.find(status.id)
    expect(db_status.text).to eq(message)
  end

  it 'should require status messages not be more than 65535 characters long' do
    message = 'a' * (65535+1)
    status_message = FactoryGirl.build(:status_message, :text => message)
    expect(status_message).not_to be_valid
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
        expect(Diaspora::Mentionable).to receive(:people_from_string).and_return(@people)
        @sm.mentions.delete_all
        @sm.create_mentions
        expect(@sm.mentions(true).map{|m| m.person}.to_set).to eq(@people.to_set)
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
        expect(@sm).to receive(:create_mentions)
        @sm.mentioned_people
      end
      it 'returns the mentioned people' do
        @sm.mentions.delete_all
        expect(@sm.mentioned_people.to_set).to eq(@people.to_set)
      end
      it 'does not call create_mentions if there are mentions in the db' do
        expect(@sm).not_to receive(:create_mentions)
        @sm.mentioned_people
      end
    end

    describe "#mentions?" do
      it 'returns true if the person was mentioned' do
        expect(@sm.mentions?(@people[0])).to be true
      end

      it 'returns false if the person was not mentioned' do
        expect(@sm.mentions?(FactoryGirl.build(:person))).to be false
      end
    end

    describe "#notify_person" do
      it 'notifies the person mentioned' do
        expect(Notification).to receive(:notify).with(alice, anything, anything)
        @sm.notify_person(alice.person)
      end
    end

    describe "#filter_mentions" do
      it 'calls Diaspora::Mentionable#filter_for_aspects' do
        msg = FactoryGirl.build(:status_message_in_aspect)

        msg_txt = msg.raw_message
        author_usr = msg.author.owner
        aspect_id = author_usr.aspects.first.id

        expect(Diaspora::Mentionable).to receive(:filter_for_aspects)
                             .with(msg_txt, author_usr, aspect_id)

        msg.send(:filter_mentions)
      end

      it "doesn't do anything when public" do
        msg = FactoryGirl.build(:status_message, public: true)
        expect(Diaspora::Mentionable).not_to receive(:filter_for_aspects)

        msg.send(:filter_mentions)
      end
    end
  end

  describe "#nsfw" do
    it 'returns MatchObject (true) if the post contains #nsfw (however capitalised)' do
      status  = FactoryGirl.build(:status_message, :text => "This message is #nSFw")
      expect(status.nsfw).to be_truthy
    end

    it 'returns nil (false) if the post does not contain #nsfw' do
      status  = FactoryGirl.build(:status_message, :text => "This message is #sFW")
      expect(status.nsfw).to be false
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
    let(:message) { FactoryGirl.build(:status_message, text: "I hate WALRUSES!", author: @user.person) }
    let(:xml) { message.to_xml.to_s }
    let(:marshalled) { StatusMessage.from_xml(xml) }

    it 'serializes the escaped, unprocessed message' do
      text = "[url](http://example.org)<script> alert('xss should be federated');</script>"
      message.text = text
      expect(xml).to include Builder::XChar.encode(text)
    end

    it 'serializes the message' do
      expect(xml).to include "<raw_message>I hate WALRUSES!</raw_message>"
    end

    it 'serializes the author address' do
      expect(xml).to include(@user.person.diaspora_handle)
    end

    describe '.from_xml' do
      it 'marshals the message' do
        expect(marshalled.text).to eq("I hate WALRUSES!")
      end

      it 'marshals the guid' do
        expect(marshalled.guid).to eq(message.guid)
      end

      it 'marshals the author' do
        expect(marshalled.author).to eq(message.author)
      end

      it 'marshals the diaspora_handle' do
        expect(marshalled.diaspora_handle).to eq(message.diaspora_handle)
      end
    end

    context 'with some photos' do
      before do
        message.photos << FactoryGirl.build(:photo)
        message.photos << FactoryGirl.build(:photo)
      end

      it 'serializes the photos' do
        expect(xml).to include "photo"
        expect(xml).to include message.photos.first.remote_photo_path
      end

      describe '.from_xml' do
        it 'marshals the photos' do
          expect(marshalled.photos.size).to eq(2)
        end

        it 'handles existing photos' do
          message.photos.each(&:save!)
          expect(marshalled).to be_valid
        end
      end
    end

    context 'with a location' do
      before do
        message.location = FactoryGirl.build(:location)
      end

      it 'serializes the location' do
        expect(xml).to include "location"
        expect(xml).to include "lat"
        expect(xml).to include "lng"
      end

      describe ".from_xml" do
        it 'marshals the location' do
          expect(marshalled.location).to be_present
        end
      end
    end

    context 'with a poll' do
      before do
        message.poll = FactoryGirl.build(:poll)
      end

      it 'serializes the poll' do
        expect(xml).to include "poll"
        expect(xml).to include "question"
        expect(xml).to include "poll_answer"
      end

      describe ".from_xml" do
        it 'marshals the poll' do
          expect(marshalled.poll).to be_present
        end

        it 'marshals the poll answers' do
          expect(marshalled.poll.poll_answers.size).to eq(2)
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
      expect(@photos.all?{|p| p.reload.pending}).to be false
    end
    it 'dispatches any attached photos' do
      expect(alice).to receive(:dispatch_post).twice
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
      expect(Workers::GatherOEmbedData).to receive(:perform_async).with(instance_of(Fixnum), instance_of(String))
      sm.save
    end

    describe '#contains_oembed_url_in_text?' do
      it 'returns the oembed urls found in the raw message' do
        sm = FactoryGirl.build(:status_message, :text => @message_text)
        expect(sm.contains_oembed_url_in_text?).not_to be_nil
        expect(sm.oembed_url).to eq(@youtube_url)
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
      expect(Workers::GatherOpenGraphData).to receive(:perform_async).with(instance_of(Fixnum), instance_of(String))
      sm.save
    end

    describe '#contains_open_graph_url_in_text?' do
      it 'returns the opengraph urls found in the raw message' do
        sm = FactoryGirl.build(:status_message, :text => @message_text)
        expect(sm.contains_open_graph_url_in_text?).not_to be_nil
        expect(sm.open_graph_url).to eq(@ninegag_url)
      end
      it 'returns nil if the link is from trusted oembed provider' do
        sm = FactoryGirl.build(:status_message, :text => @oemessage_text)
        expect(sm.contains_open_graph_url_in_text?).to be_nil
        expect(sm.open_graph_url).to be_nil
      end
    end
  end
end
