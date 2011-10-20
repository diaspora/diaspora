#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Stream::Aspect do
  describe '#aspects' do
    it 'queries the user given initialized aspect ids' do
      alice = stub.as_null_object
      stream = Stream::Aspect.new(alice, [1,2,3])

      alice.aspects.should_receive(:where)
      stream.aspects
    end

    it "returns all the user's aspects if no aspect ids are specified" do
      alice = stub.as_null_object
      stream = Stream::Aspect.new(alice, [])

      alice.aspects.should_not_receive(:where)
      stream.aspects
    end

    it 'filters aspects given a user' do
      alice = stub(:aspects => [stub(:id => 1)])
      alice.aspects.stub(:where).and_return(alice.aspects)
      stream = Stream::Aspect.new(alice, [1,2,3])

      stream.aspects.should == alice.aspects
    end
  end

  describe '#aspect_ids' do
    it 'maps ids from aspects' do
      alice = stub.as_null_object
      aspects = stub.as_null_object

      stream = Stream::Aspect.new(alice, [1,2])

      stream.should_receive(:aspects).and_return(aspects)
      aspects.should_receive(:map)
      stream.aspect_ids
    end
  end

  describe '#posts' do
    before do
      @alice = stub.as_null_object
    end

    it 'calls visible posts for the given user' do
      stream = Stream::Aspect.new(@alice, [1,2])

      @alice.should_receive(:visible_shareables).and_return(stub.as_null_object)
      stream.posts
    end

    it 'is called with 3 types' do
      stream = Stream::Aspect.new(@alice, [1,2], :order => 'created_at')
      @alice.should_receive(:visible_shareables).with(Post, hash_including(:type=> ['StatusMessage', 'Reshare', 'ActivityStreams::Photo'])).and_return(stub.as_null_object)
      stream.posts
    end

    it 'respects ordering' do 
      stream = Stream::Aspect.new(@alice, [1,2], :order => 'created_at')
      @alice.should_receive(:visible_shareables).with(Post, hash_including(:order => 'created_at DESC')).and_return(stub.as_null_object)
      stream.posts
    end

    it 'respects max_time' do
      stream = Stream::Aspect.new(@alice, [1,2], :max_time => 123)
      @alice.should_receive(:visible_shareables).with(Post, hash_including(:max_time => instance_of(Time))).and_return(stub.as_null_object)
      stream.posts
    end

    it 'passes for_all_aspects to visible posts' do
      stream = Stream::Aspect.new(@alice, [1,2], :max_time => 123)
      all_aspects = mock
      stream.stub(:for_all_aspects?).and_return(all_aspects)
      @alice.should_receive(:visible_shareables).with(Post, hash_including(:all_aspects? => all_aspects)).and_return(stub.as_null_object)
      stream.posts
    end
  end

  describe '#people' do
    it 'should call Person.all_from_aspects' do
      class Person ; end

      alice = stub.as_null_object
      aspect_ids = [1,2,3]
      stream = Stream::Aspect.new(alice, [])

      stream.stub(:aspect_ids).and_return(aspect_ids)
      Person.should_receive(:all_from_aspects).with(stream.aspect_ids, alice).and_return(stub(:includes => :profile))
      stream.people
    end
  end

  describe '#aspect' do
    before do
      alice = stub.as_null_object
      @stream = Stream::Aspect.new(alice, [1,2])
    end

    it "returns an aspect if the stream is not for all the user's aspects" do
      @stream.stub(:for_all_aspects?).and_return(false)
      @stream.aspect.should_not be_nil
    end

    it "returns nothing if the stream is not for all the user's aspects" do
      @stream.stub(:for_all_aspects?).and_return(true)
      @stream.aspect.should be_nil
    end
  end

  describe 'for_all_aspects?' do
    before do
      alice = stub.as_null_object
      alice.aspects.stub(:size).and_return(2)
      @stream = Stream::Aspect.new(alice, [1,2])
    end

    it "is true if the count of aspect_ids is equal to the size of the user's aspect count" do
      @stream.aspect_ids.stub(:length).and_return(2)
      @stream.should be_for_all_aspects
    end

    it "is false if the count of aspect_ids is not equal to the size of the user's aspect count" do
      @stream.aspect_ids.stub(:length).and_return(1)
      @stream.should_not be_for_all_aspects
    end
  end

  describe '.ajax_stream?' do
    before do
      @original_value = AppConfig[:redis_cache] 
      @stream = Stream::Aspect.new(stub, stub)
    end

    after do
      AppConfig[:redis_cache] = @original_value
    end

    context 'if we are not caching with redis' do
      before do
        AppConfig[:redis_cache] = false
      end

      it 'is true if stream is for all aspects?' do
        @stream.stub(:for_all_aspects?).and_return(true)
        @stream.ajax_stream?.should be_true
      end

      it 'is false if it is not for all aspects' do
        @stream.stub(:for_all_aspects?).and_return(false)
        @stream.ajax_stream?.should be_false
      end
    end

    context 'if we are caching with redis' do
      it 'returns false' do
        AppConfig[:redis_cache] = true
        @stream.ajax_stream?.should be_false
      end
    end
  end

  describe 'shared behaviors' do
    before do
      @stream = Stream::Aspect.new(alice, alice.aspects.map(&:id))
    end
    it_should_behave_like 'it is a stream'
  end

  describe "#publisher" do
    before do
      @stream = Stream::Aspect.new(alice, alice.aspects.map(&:id))
      @stream.stub(:welcome?).and_return(false)
    end

    it 'does not use prefill text by default' do
      @stream.should_not_receive(:publisher_prefill)

      @stream.publisher
    end

    it 'checks welcome?' do
      @stream.should_receive(:welcome?).and_return(true)

      @stream.publisher
    end

    it 'creates a welcome publisher for new user' do
      @stream.stub(:welcome?).and_return(true)
      @stream.should_receive(:publisher_prefill).and_return("abc")

      Publisher.should_receive(:new).with(alice, hash_including(:open => true, :prefill => "abc", :public => true))
      @stream.publisher
    end

    it 'creates a default publisher for returning users' do
      Publisher.should_receive(:new).with(alice)
      @stream.publisher
    end
  end

  describe "#publisher_prefill" do
    before do
      @tag = ActsAsTaggableOn::Tag.find_or_create_by_name("cats")
      @tag_following = alice.tag_followings.create(:tag_id => @tag.id)

      @stream = Stream::Aspect.new(alice, alice.aspects.map(&:id))
    end
    
    it 'returns includes new user hashtag' do
      @stream.send(:publisher_prefill).include?("#newhere").should be_true
    end

    it 'includes followed hashtags' do
      @stream.send(:publisher_prefill).include?("#cats").should be_true
    end
  end

  describe "#welcome?" do
    it 'returns true if user is getting started' do
      alice.getting_started = true

      Stream::Aspect.new(alice, alice.aspects.map(&:id)).send(:welcome?).should be_true
    end

    it 'returns false if user is getting started' do
      alice.getting_started = false

      Stream::Aspect.new(alice, alice.aspects.map(&:id)).send(:welcome?).should be_false
    end
  end
end
