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

    it 'allows me to comment on my local contacts post' do
      post = Factory(:status_message, :author => bob.person)
      @stream.can_comment?(post).should be_true
    end

    it 'allows me to comment on my own post' do
      post = Factory(:status_message, :author => alice.person)
      @stream.can_comment?(post).should be_true
    end

    it 'allows me to comment on any local public post' do
      post = Factory(:status_message, :author => eve.person)
      @stream.can_comment?(post).should be_true
    end

    it 'allows me to comment on a remote contacts post' do
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
