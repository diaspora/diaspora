# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

describe Stream::Aspect do
  describe '#aspects' do
    it 'queries the user given initialized aspect ids' do
      alice = double.as_null_object
      stream = Stream::Aspect.new(alice, [1,2,3])

      expect(alice.aspects).to receive(:where)
      stream.aspects
    end

    it "returns all the user's aspects if no aspect ids are specified" do
      alice = double.as_null_object
      stream = Stream::Aspect.new(alice, [])

      expect(alice.aspects).not_to receive(:where)
      stream.aspects
    end

    it 'filters aspects given a user' do
      alice = double(:aspects => [double(:id => 1)])
      allow(alice.aspects).to receive(:where).and_return(alice.aspects)
      stream = Stream::Aspect.new(alice, [1,2,3])

      expect(stream.aspects).to eq(alice.aspects)
    end
  end

  describe '#aspect_ids' do
    it 'maps ids from aspects' do
      alice = double.as_null_object
      aspects = double.as_null_object

      stream = Stream::Aspect.new(alice, [1,2])

      expect(stream).to receive(:aspects).and_return(aspects)
      expect(aspects).to receive(:map)
      stream.aspect_ids
    end
  end

  describe '#posts' do
    before do
      @alice = double.as_null_object
    end

    it 'calls visible posts for the given user' do
      stream = Stream::Aspect.new(@alice, [1,2])

      expect(@alice).to receive(:visible_shareables).and_return(double.as_null_object)
      stream.posts
    end

    it 'is called with 2 types' do
      stream = Stream::Aspect.new(@alice, [1,2], :order => 'created_at')
      expect(@alice).to receive(:visible_shareables).with(Post, hash_including(:type=> ['StatusMessage', 'Reshare'])).and_return(double.as_null_object)
      stream.posts
    end

    it 'respects ordering' do
      stream = Stream::Aspect.new(@alice, [1,2], :order => 'created_at')
      expect(@alice).to receive(:visible_shareables).with(Post, hash_including(:order => 'created_at DESC')).and_return(double.as_null_object)
      stream.posts
    end

    it 'respects max_time' do
      stream = Stream::Aspect.new(@alice, [1,2], :max_time => 123)
      expect(@alice).to receive(:visible_shareables).with(Post, hash_including(:max_time => instance_of(Time))).and_return(double.as_null_object)
      stream.posts
    end

    it 'passes for_all_aspects to visible posts' do
      stream = Stream::Aspect.new(@alice, [1,2], :max_time => 123)
      all_aspects = double
      allow(stream).to receive(:for_all_aspects?).and_return(all_aspects)
      expect(@alice).to receive(:visible_shareables).with(Post, hash_including(:all_aspects? => all_aspects)).and_return(double.as_null_object)
      stream.posts
    end
  end

  describe '#people' do
    it 'should call Person.all_from_aspects' do
      class Person ; end

      alice = double.as_null_object
      aspect_ids = [1,2,3]
      stream = Stream::Aspect.new(alice, [])

      allow(stream).to receive(:aspect_ids).and_return(aspect_ids)
      expect(Person).to receive(:unique_from_aspects).with(stream.aspect_ids, alice).and_return(double(:includes => :profile))
      stream.people
    end
  end

  describe '#aspect' do
    before do
      alice = double.as_null_object
      @stream = Stream::Aspect.new(alice, [1,2])
    end

    it "returns an aspect if the stream is not for all the user's aspects" do
      allow(@stream).to receive(:for_all_aspects?).and_return(false)
      expect(@stream.aspect).not_to be_nil
    end

    it "returns nothing if the stream is not for all the user's aspects" do
      allow(@stream).to receive(:for_all_aspects?).and_return(true)
      expect(@stream.aspect).to be_nil
    end
  end

  describe 'for_all_aspects?' do
    before do
      alice = double.as_null_object
      allow(alice.aspects).to receive(:size).and_return(2)
      @stream = Stream::Aspect.new(alice, [1,2])
    end

    it "is true if the count of aspect_ids is equal to the size of the user's aspect count" do
      allow(@stream.aspect_ids).to receive(:length).and_return(2)
      expect(@stream).to be_for_all_aspects
    end

    it "is false if the count of aspect_ids is not equal to the size of the user's aspect count" do
      allow(@stream.aspect_ids).to receive(:length).and_return(1)
      expect(@stream).not_to be_for_all_aspects
    end
  end

  describe 'shared behaviors' do
    before do
      @stream = Stream::Aspect.new(alice, alice.aspects.map(&:id))
    end
    it_should_behave_like 'it is a stream'
  end
end
