#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'aspect_stream'

describe AspectStream do
  describe '#aspects' do
    it 'queries the user given initialized aspect ids' do
      alice = stub.as_null_object
      stream = AspectStream.new(alice, [1,2,3])

      alice.aspects.should_receive(:where)
      stream.aspects
    end

    it "returns all the user's aspects if no aspect ids are specified" do
      alice = stub.as_null_object
      stream = AspectStream.new(alice, [])

      alice.aspects.should_not_receive(:where)
      stream.aspects
    end

    it 'filters aspects given a user' do
      alice = stub(:aspects => [stub(:id => 1)])
      alice.aspects.stub(:where).and_return(alice.aspects)
      stream = AspectStream.new(alice, [1,2,3])

      stream.aspects.should == alice.aspects
    end
  end

  describe '#aspect_ids' do
    it 'maps ids from aspects' do
      alice = stub.as_null_object
      aspects = stub.as_null_object

      stream = AspectStream.new(alice, [1,2])

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
      stream = AspectStream.new(@alice, [1,2])

      @alice.should_receive(:visible_posts).and_return(stub.as_null_object)
      stream.posts
    end

    it 'is called with 3 types' do
      stream = AspectStream.new(@alice, [1,2], :order => 'created_at')
      @alice.should_receive(:visible_posts).with(hash_including(:type=> ['StatusMessage', 'Reshare', 'ActivityStreams::Photo'])).and_return(stub.as_null_object)
      stream.posts
    end

    it 'respects ordering' do 
      stream = AspectStream.new(@alice, [1,2], :order => 'created_at')
      @alice.should_receive(:visible_posts).with(hash_including(:order => 'created_at DESC')).and_return(stub.as_null_object)
      stream.posts
    end

    it 'respects max_time' do
      stream = AspectStream.new(@alice, [1,2], :max_time => 123)
      @alice.should_receive(:visible_posts).with(hash_including(:max_time => 123)).and_return(stub.as_null_object)
      stream.posts
    end
  end

  describe '#people' do
    it 'should call Person.all_from_aspects' do
      class Person ; end

      alice = stub.as_null_object
      aspect_ids = [1,2,3]
      stream = AspectStream.new(alice, [])

      stream.stub(:aspect_ids).and_return(aspect_ids)
      Person.should_receive(:all_from_aspects).with(stream.aspect_ids, alice).and_return(stub(:includes => :profile))
      stream.people
    end
  end

  describe '#aspect' do
    before do
      alice = stub.as_null_object
      @stream = AspectStream.new(alice, [1,2])
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
      @stream = AspectStream.new(alice, [1,2])
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
      @stream = AspectStream.new(stub, stub)
    end
    it 'is true stream is for all aspects?' do
      @stream.stub(:for_all_aspects?).and_return(true)
      @stream.ajax_stream?.should be_true
    end

    it 'is false if it is not for all aspects' do
      @stream.stub(:for_all_aspects?).and_return(false)
      @stream.ajax_stream?.should be_false
    end
  end
end
