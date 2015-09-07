require "spec_helper"

describe Services::Tumblr, type: :model do
  let(:user) { alice }
  let(:post) { user.post(:status_message, text: "hello", to: user.aspects.first.id) }
  let(:service) { Services::Tumblr.new(access_token: "yeah", access_secret: "foobar") }

  describe "#post" do
    let(:post_id) { "bla" }
    let(:post_request) { {body: service.build_tumblr_post(post, "")} }
    let(:post_response) { {status: 201, body: {response: {id: post_id}}.to_json} }

    before do
      user.services << service
      stub_request(:get, "http://api.tumblr.com/v2/user/info").to_return(status: 200, body: user_info)
    end

    context "with multiple blogs" do
      let(:user_info) {
        {response: {user: {blogs: [
          {primary: false, url: "http://foo.tumblr.com"},
          {primary: true, url: "http://bar.tumblr.com"}
        ]}}}.to_json
      }

      it "posts a status message to the primary blog and stores the id" do
        stub_request(:post, "http://api.tumblr.com/v2/blog/bar.tumblr.com/post")
         .with(post_request).to_return(post_response)

        expect(post).to receive(:tumblr_ids=).with({"bar.tumblr.com" => post_id}.to_json)

        service.post(post)
      end
    end

    context "with a single blog" do
      let(:user_info) { {response: {user: {blogs: [{url: "http://foo.tumblr.com"}]}}}.to_json }

      it "posts a status message to the returned blog" do
        stub_request(:post, "http://api.tumblr.com/v2/blog/foo.tumblr.com/post")
         .with(post_request).to_return(post_response)

        service.post(post)
      end
    end
  end

  describe "#delete_post" do
    it "removes posts from tumblr" do
      stub_request(:post, "http://api.tumblr.com/v2/blog/foodbar.tumblr.com/post/delete")
        .to_return(status: 200)

      service.delete_post(post)
    end
  end
end
