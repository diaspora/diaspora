require 'spec_helper'
require File.join(Rails.root, 'spec', 'shared_behaviors', 'stream')

describe TagStream do
  before do
    @stream = TagStream.new(Factory(:user), :max_time => Time.now, :order => 'updated_at')
    @stream.stub(:tag_string).and_return("foo")
  end

  describe 'shared behaviors' do
    it_should_behave_like 'it is a stream'
  end

  describe '.can_comment?' do
    before do
      @stream = TagStream.new(alice)
      @stream.stub(:people).and_return([bob.person])
    end

    it 'returns true if user is a contact of the post author' do
      post = Factory(:status_message, :author => bob.person)
      @stream.can_comment?(post).should be_true
    end 

    it 'returns true if a user is the author of the post' do 
      post = Factory(:status_message, :author => alice.person)
      @stream.can_comment?(post).should be_true
    end

    it 'returns false otherwise' do
      post = Factory(:status_message, :author => eve.person)
      @stream.can_comment?(post).should be_false
    end
  end
end
