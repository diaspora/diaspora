# frozen_string_literal: true

describe Services::Wordpress, type: :model do
  before do
    @user = alice
    @post = @user.post(:status_message,
                       text: "Hello there. This is a **Wordpress** post that we hope to turn into something else.",
                       to:   @user.aspects.first.id)

    @service = Services::Wordpress.new(nickname:     "andrew",
                                       access_token: "abc123",
                                       uid:          "123")
    @user.services << @service
  end

  describe "#post" do
    it "posts a status message to wordpress" do
      stub_request(:post, "https://public-api.wordpress.com/rest/v1/sites/123/posts/new").to_return(
        status:  200,
        body:    {ID: 68}.to_json,
        headers: {}
      )
      @service.post(@post)
    end
  end

  describe "#post_body" do
    it "truncates content for use in title" do
      expect(@service.post_body(@post)[:title]).to eq(
        "Hello there. This is a Wordpress post that we hope to turn into som..."
      )
    end
    it "converts markdown tags" do
      expect(@service.post_body(@post)[:content]).to match("<strong>Wordpress</strong>")
    end
  end
end
