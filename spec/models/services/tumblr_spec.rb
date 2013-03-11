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
      response = mock
      response.stub(:body).and_return('{"response": {"user": {"blogs": [{"url": "http://foo.tumblr.com"}]}}}')
      OAuth::AccessToken.any_instance.should_receive(:get).with("/v2/user/info").and_return(response)
      OAuth::AccessToken.any_instance.should_receive(:post)
      @service.post(@post)
    end
  end
end

