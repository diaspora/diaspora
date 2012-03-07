require 'spec_helper'

describe Services::Tumblr do

  before do
    @user = alice
    @post = @user.post(:status_message, :text => "hello", :to =>@user.aspects.first.id)
    @service = Services::Tumblr.new(:access_token => "yeah", :access_secret => "foobar")
    @user.services << @service
  end

  describe '#post' do
    it 'posts a status message to tumblr' do
      OAuth::AccessToken.any_instance.should_receive(:post)
      @service.post(@post)
    end

    it 'swallows exception raised by tumblr not being webscale' do
      OAuth::AccessToken.any_instance.should_receive(:post).and_raise(StandardError)
      @service.post(@post)
    end
  end
end

