require 'spec_helper'
require File.join(Rails.root, 'spec', 'shared_behaviors', 'stream')
describe Stream::Base do
  before do
    @stream = Stream::Base.new(alice)
  end

  describe '.can_comment?' do
    before do
      @person = Factory(:person)
      @stream.stub(:people).and_return([bob.person, eve.person, @person])
    end

    it 'returns true if user is a contact of the post author' do
      post = Factory(:status_message, :author => bob.person)
      @stream.can_comment?(post).should be_true
    end

    it 'returns true if a user is the author of the post' do
      post = Factory(:status_message, :author => alice.person)
      @stream.can_comment?(post).should be_true
    end

    it 'returns true if the author of the post is local' do
      post = Factory(:status_message, :author => eve.person)
      @stream.can_comment?(post).should be_true
    end

    it 'returns true if person is remote and is a contact' do
      Contact.create!(:user => @stream.user, :person => @person)
      post = Factory(:status_message, :author => @person)
      @stream.can_comment?(post).should be_true
    end

    it 'returns false if person is remote and not a contact' do
      post = Factory(:status_message, :author => @person)
      @stream.can_comment?(post).should be_false
    end
  end

  describe 'shared behaviors' do
    it_should_behave_like 'it is a stream'
  end
end
