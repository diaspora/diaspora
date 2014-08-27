require 'spec_helper'

shared_examples_for 'it is a stream' do
  context 'required methods for display' do
    it '#title' do
      expect(@stream.title).not_to be_nil
    end

    it '#posts' do
      expect(@stream.posts).not_to be_nil
    end

    it '#people' do
      expect(@stream.people).not_to be_nil
    end

    it '#publisher_opts' do
      expect(@stream.send(:publisher_opts)).not_to be_nil
    end

    it 'has a #contacts title' do
      expect(@stream.contacts_title).not_to be_nil
    end

    it 'has a contacts link' do
      expect(@stream.contacts_link).not_to be_nil
    end

    it 'should make the stream a time object' do
      @stream.max_time = 123
      expect(@stream.max_time).to be_a(Time)
    end

    it 'should always have an order (default created_at)' do
      @stream.order=nil
      expect(@stream.order).not_to be_nil
    end

    it 'initializes a publisher' do
      expect(@stream.publisher).to be_a(Publisher)
    end
  end
end
