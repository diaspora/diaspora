# frozen_string_literal: true

describe PollParticipationsController, type: :controller do
  let(:poll_post) { FactoryGirl.create(:status_message_with_poll, public: true) }
  let(:poll_answer) { poll_post.poll.poll_answers.first }

  before do
    sign_in alice, scope: :user
    request.env["HTTP_ACCEPT"] = "application/json"
  end

  describe "voting on poll" do
    it "succeeds" do
      post :create, params: {post_id: poll_post.id, poll_answer_id: poll_answer.id}
      expect(response.status).to eq(201)
      poll_participation = JSON.parse(response.body)["poll_participation"]
      expect(poll_participation["poll_answer_id"]).to eq(poll_answer.id)
    end

    it "fails to vote twice" do
      post :create, params: {post_id: poll_post.id, poll_answer_id: poll_answer.id}
      expect(response.status).to eq(201)
      post :create, params: {post_id: poll_post.id, poll_answer_id: poll_answer.id}
      expect(response.status).to eq(403)
    end

    it "fails with bad answer id" do
      expect {
        post :create, params: {post_id: poll_post.id, poll_answer_id: -1}
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "fails with bad post id" do
      expect { post :create, params: {post_id: -1, poll_answer_id: poll_answer.id} }
        .to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
