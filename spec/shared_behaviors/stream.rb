require 'spec_helper'

shared_examples_for 'it is a stream' do
  context 'required methods for display' do
    it '#title' do
      @stream.title.should_not be_nil
    end

    it '#posts' do
      @stream.posts.should_not be_nil
    end

    it '#people' do
      @stream.people.should_not be_nil
    end

    it '#publisher_opts' do
      @stream.send(:publisher_opts).should_not be_nil
    end

    it 'has a #contacts title' do
      @stream.contacts_title.should_not be_nil
    end

    it 'has a contacts link' do
      @stream.contacts_link.should_not be_nil
    end

    it 'should make the stream a time object' do
      @stream.max_time = 123
      @stream.max_time.should be_a(Time)
    end

    it 'should always have an order (default created_at)' do
      @stream.order=nil
      @stream.order.should_not be_nil
    end

    it 'initializes a publisher' do
      @stream.publisher.should be_a(Publisher)
    end
  end
end
