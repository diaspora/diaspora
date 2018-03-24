# frozen_string_literal: true

require "spec_helper"

describe PostsController, type: :controller do
  describe "#show" do
    it "generates the post_json fixture", fixture: true do
      post = alice.post(:status_message, text: "hello world", public: true)
      get :show, params: {id: post.id}, format: :json
      save_fixture(response.body, "post_json")
    end
  end
end
