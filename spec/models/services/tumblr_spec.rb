require 'spec_helper'

describe Services::Tumblr do

  before do
    @user = alice
    @post = @user.post(:status_message, :text => "hello", :to =>@user.aspects.first.id)
    @service = Services::Tumblr.new(:access_token => "yeah", :access_secret => "foobar")
    @user.services << @service
  end

  describe '#post' do
    it 'posts a status message to tumblr and saves the returned ids' do
      response = double(body: '{"response": {"user": {"blogs": [{"url": "http://foo.tumblr.com"}]}}}')
      OAuth::AccessToken.any_instance.should_receive(:get)
      .with("/v2/user/info")
      .and_return(response)

      response = double(code: "201", body: '{"response": {"id": "bla"}}')
      OAuth::AccessToken.any_instance.should_receive(:post)
      .with("/v2/blog/foo.tumblr.com/post", @service.build_tumblr_post(@post, ''))
      .and_return(response)

      @post.should_receive(:tumblr_ids=).with({"foo.tumblr.com" => "bla"}.to_json)

      @service.post(@post)
    end
  end

  describe '#delete_post' do
    it 'removes posts from tumblr' do
      stub_request(:post, "http://api.tumblr.com/v2/blog/foodbar.tumblr.com/post/delete").
        to_return(:status => 200)

      @service.delete_post(@post)
    end
  end
end

