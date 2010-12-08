require 'spec_helper'

describe Services::Twitter do 

  before do
    @user = make_user
    @user.aspects.create(:name => "whatever")
    @post = @user.post(:status_message, :message => "hello", :to =>@user.aspects.first.id)
    @service = Services::Twitter.new(:access_token => "yeah", :access_secret => "foobar")
    @user.services << @service
  end

  describe '#post' do
    it 'posts a status message to twitter' do
      Twitter.should_receive(:update).with(@post.message) 
      @service.post(@post.message)
    end
  end
end
