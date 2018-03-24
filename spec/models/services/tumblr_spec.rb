# frozen_string_literal: true

describe Services::Tumblr, type: :model do
  let(:user) { alice }
  let(:post) { user.post(:status_message, text: "hello", to: user.aspects.first.id) }
  let(:service) { Services::Tumblr.new(access_token: "yeah", access_secret: "foobar") }
  let(:post_id) { "bla" }

  describe "#post" do
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
        stub = stub_request(:post, "http://api.tumblr.com/v2/blog/bar.tumblr.com/post")
               .with(post_request).to_return(post_response)

        expect(post).to receive(:tumblr_ids=).with({"bar.tumblr.com" => post_id}.to_json)

        service.post(post)

        expect(stub).to have_been_requested
      end
    end

    context "with a single blog" do
      let(:user_info) { {response: {user: {blogs: [{url: "http://foo.tumblr.com"}]}}}.to_json }

      it "posts a status message to the returned blog" do
        stub = stub_request(:post, "http://api.tumblr.com/v2/blog/foo.tumblr.com/post")
               .with(post_request).to_return(post_response)

        service.post(post)

        expect(stub).to have_been_requested
      end
    end
  end

  describe "#post_opts" do
    it "returns the tumblr_ids of the post" do
      post.tumblr_ids = {"foodbar.tumblr.com" => post_id}.to_json
      expect(service.post_opts(post)).to eq(tumblr_ids: post.tumblr_ids)
    end

    it "returns nil when the post has no tumblr_ids" do
      expect(service.post_opts(post)).to be_nil
    end
  end

  describe "#delete_from_service" do
    it "removes posts from tumblr" do
      tumblr_ids = {"foodbar.tumblr.com" => post_id}.to_json
      stub = stub_request(:post, "http://api.tumblr.com/v2/blog/foodbar.tumblr.com/post/delete")
             .with(body: {"id" => post_id}).to_return(status: 200)

      service.delete_from_service(tumblr_ids: tumblr_ids)

      expect(stub).to have_been_requested
    end
  end
end
