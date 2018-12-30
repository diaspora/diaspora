# frozen_sTring_literal: true

require "spec_helper"

describe Api::V1::PostInteractionsController do
  let(:auth) {
    FactoryGirl.create(
      :auth_with_default_scopes,
      scopes: %w[openid public:read public:modify private:read private:modify interactions]
    )
  }

  let(:auth_public_only) {
    FactoryGirl.create(
      :auth_with_default_scopes,
      scopes: %w[openid public:read public:modify interactions]
    )
  }

  let(:auth_minimum_scopes) {
    FactoryGirl.create(:auth_with_default_scopes)
  }

  let!(:access_token) { auth.create_access_token.to_s }
  let!(:access_token_public_only) { auth_public_only.create_access_token.to_s }
  let!(:access_token_minimum_scopes) { auth_minimum_scopes.create_access_token.to_s }
  let(:invalid_token) { SecureRandom.hex(9) }

  before do
    @status = alice.post(
      :status_message,
      text:   "hello @{#{bob.diaspora_handle}} and @{#{eve.diaspora_handle}}from Alice!",
      public: true,
      to:     "all"
    )

    alice_shared_aspect = alice.aspects.create(name: "shared aspect")
    alice.share_with(auth_public_only.user.person, alice_shared_aspect)
    alice.share_with(auth.user.person, alice_shared_aspect)
    alice.share_with(auth_minimum_scopes.user.person, alice_shared_aspect)

    @shared_post = alice.post(:status_message, text: "to aspect only", public: false, to: alice_shared_aspect.id)
  end

  describe "#subscribe" do
    context "succeeds" do
      it "with proper guid and access token" do
        participation_count = @status.participations.count
        post(
          api_v1_post_subscribe_path(@status.guid),
          params: {
            access_token: access_token
          }
        )
        expect(response.status).to eq(204)
        expect(@status.participations.count).to eq(participation_count + 1)
      end
    end

    context "fails" do
      it "when duplicate" do
        post(
          api_v1_post_subscribe_path(@status.guid),
          params: {
            access_token: access_token
          }
        )
        expect(response.status).to eq(204)
        post(
          api_v1_post_subscribe_path(@status.guid),
          params: {
            access_token: access_token
          }
        )
        expect(response.status).to eq(422)
      end

      it "with improper guid" do
        post(
          api_v1_post_subscribe_path("999_999_999"),
          params: {
            access_token: access_token
          }
        )
        expect(response.status).to eq(404)
        expect(response.body).to eq(I18n.t("api.endpoint_errors.posts.post_not_found"))
      end

      it "with insufficient token" do
        post(
          api_v1_post_subscribe_path(@status.guid),
          params: {
            access_token: access_token_minimum_scopes
          }
        )
        expect(response.status).to eq(403)
      end

      it "on private post without private token" do
        post(
          api_v1_post_subscribe_path(@shared_post.guid),
          params: {
            access_token: access_token_public_only
          }
        )
        expect(response.status).to eq(404)
      end

      it "with invalid token" do
        post(
          api_v1_post_subscribe_path(@status.guid),
          params: {
            access_token: invalid_token
          }
        )
        expect(response.status).to eq(401)
      end
    end
  end

  describe "#hide" do
    context "succeeds" do
      it "with proper guid and access token" do
        hidden_count = auth.user.hidden_shareables.count
        post(
          api_v1_post_hide_path(@status.guid),
          params: {
            access_token: access_token
          }
        )
        expect(response.status).to eq(204)
        expect(auth.user.reload.hidden_shareables.count).to eq(hidden_count + 1)
      end
    end

    context "fails" do
      it "with improper guid" do
        post(
          api_v1_post_hide_path("999_999_999"),
          params: {
            access_token: access_token
          }
        )
        expect(response.status).to eq(404)
        expect(response.body).to eq(I18n.t("api.endpoint_errors.posts.post_not_found"))
      end

      it "with insufficient token" do
        post(
          api_v1_post_hide_path(@status.guid),
          params: {
            access_token: access_token_minimum_scopes
          }
        )
        expect(response.status).to eq(403)
      end

      it "on private post without private token" do
        post(
          api_v1_post_hide_path(@shared_post.guid),
          params: {
            access_token: access_token_public_only
          }
        )
        expect(response.status).to eq(404)
      end

      it "with invalid token" do
        post(
          api_v1_post_hide_path(@status.guid),
          params: {
            access_token: invalid_token
          }
        )
        expect(response.status).to eq(401)
      end
    end
  end

  describe "#mute" do
    before do
      post(
        api_v1_post_subscribe_path(@status.guid),
        params: {
          access_token: access_token
        }
      )
      expect(response.status).to eq(204)
    end

    context "succeeds" do
      it "with proper guid and access token" do
        count = @status.participations.count
        post(
          api_v1_post_mute_path(@status.guid),
          params: {
            access_token: access_token
          }
        )
        expect(response.status).to eq(204)
        expect(@status.participations.count).to eq(count - 1)
      end
    end

    context "fails" do
      it "with improper guid" do
        post(
          api_v1_post_mute_path("999_999_999"),
          params: {
            access_token: access_token
          }
        )
        expect(response.status).to eq(404)
        expect(response.body).to eq(I18n.t("api.endpoint_errors.posts.post_not_found"))
      end

      it "when not subscribed already" do
        post(
          api_v1_post_mute_path(@status.guid),
          params: {
            access_token: access_token
          }
        )
        expect(response.status).to eq(204)
        post(
          api_v1_post_mute_path(@status.guid),
          params: {
            access_token: access_token
          }
        )
        expect(response.status).to eq(404)
      end

      it "with insufficient token" do
        post(
          api_v1_post_mute_path(@status.guid),
          params: {
            access_token: access_token_minimum_scopes
          }
        )
        expect(response.status).to eq(403)
      end

      it "on private post without private token" do
        post(
          api_v1_post_mute_path(@shared_post.guid),
          params: {
            access_token: access_token_public_only
          }
        )
        expect(response.status).to eq(404)
      end

      it "with invalid token" do
        post(
          api_v1_post_mute_path(@status.guid),
          params: {
            access_token: invalid_token
          }
        )
        expect(response.status).to eq(401)
      end
    end
  end

  describe "#report" do
    context "succeeds" do
      it "with proper guid and access token" do
        report_count = @status.reports.count
        post(
          api_v1_post_report_path(@status.guid),
          params: {
            reason:       "My reason",
            access_token: access_token
          }
        )
        expect(response.status).to eq(204)
        expect(@status.reports.count).to eq(report_count + 1)
      end
    end

    context "fails" do
      it "with improper guid" do
        post(
          api_v1_post_report_path("999_999_999"),
          params: {
            reason:       "My reason",
            access_token: access_token
          }
        )
        expect(response.status).to eq(404)
        expect(response.body).to eq(I18n.t("api.endpoint_errors.posts.post_not_found"))
      end

      it "when already reported" do
        post(
          api_v1_post_report_path(@status.guid),
          params: {
            reason:       "My reason",
            access_token: access_token
          }
        )
        expect(response.status).to eq(204)
        post(
          api_v1_post_report_path(@status.guid),
          params: {
            reason:       "My reason",
            access_token: access_token
          }
        )
        expect(response.status).to eq(409)
        expect(response.body).to eq(I18n.t("api.endpoint_errors.posts.cant_report"))
      end

      it "when missing reason" do
        post(
          api_v1_post_report_path(@status.guid),
          params: {
            access_token: access_token
          }
        )
        expect(response.status).to eq(422)
        expect(response.body).to eq(I18n.t("api.endpoint_errors.posts.cant_report"))
      end

      it "with insufficient token" do
        post(
          api_v1_post_report_path(@status.guid),
          params: {
            reason:       "My reason",
            access_token: access_token_minimum_scopes
          }
        )
        expect(response.status).to eq(403)
      end

      it "on private post without private token" do
        post(
          api_v1_post_report_path(@shared_post.guid),
          params: {
            reason:       "My reason",
            access_token: access_token_public_only
          }
        )
        expect(response.status).to eq(404)
      end

      it "with invalid token" do
        post(
          api_v1_post_report_path(@status.guid),
          params: {
            reason:       "My reason",
            access_token: invalid_token
          }
        )
        expect(response.status).to eq(401)
      end
    end
  end

  describe "#vote" do
    before do
      base_params = {status_message: {text: "myText"}, public: true}
      poll_params = {poll_question: "something?", poll_answers: %w[yes no maybe]}
      merged_params = base_params.merge(poll_params)
      @poll_post = StatusMessageCreationService.new(alice).create(merged_params)
      @poll_answer = @poll_post.poll.poll_answers.first
    end

    it "succeeds" do
      post(
        api_v1_post_vote_path(@poll_post.guid),
        params: {
          poll_answer_id: @poll_answer.id,
          access_token:   access_token
        }
      )
      expect(response.status).to eq(204)
      expect(@poll_answer.reload.vote_count).to eq(1)
    end

    it "fails to vote twice" do
      post(
        api_v1_post_vote_path(@poll_post.guid),
        params: {
          poll_answer_id: @poll_answer.id,
          access_token:   access_token
        }
      )
      expect(response.status).to eq(204)
      post(
        api_v1_post_vote_path(@poll_post.guid),
        params: {
          poll_answer_id: @poll_answer.id,
          access_token:   access_token
        }
      )
      expect(response.status).to eq(422)
      expect(response.body).to eq(I18n.t("api.endpoint_errors.interactions.cant_vote"))
    end

    it "fails with bad answer id" do
      post(
        api_v1_post_vote_path(@poll_post.guid),
        params: {
          poll_answer_id: -1,
          access_token:   access_token
        }
      )
      expect(response.status).to eq(422)
      expect(response.body).to eq(I18n.t("api.endpoint_errors.interactions.cant_vote"))
    end

    it "fails with bad post id" do
      post(
        api_v1_post_vote_path("999_999_999"),
        params: {
          poll_answer_id: @poll_answer.id,
          access_token:   access_token
        }
      )
      expect(response.status).to eq(404)
      expect(response.body).to eq(I18n.t("api.endpoint_errors.posts.post_not_found"))
    end

    it "with insufficient token" do
      post(
        api_v1_post_vote_path(@poll_post.guid),
        params: {
          poll_answer_id: @poll_answer.id,
          access_token:   access_token_minimum_scopes
        }
      )
      expect(response.status).to eq(403)
    end

    it "on private post without private token" do
      post(
        api_v1_post_vote_path(@shared_post.guid),
        params: {
          poll_answer_id: @poll_answer.id,
          access_token:   access_token_public_only
        }
      )
      expect(response.status).to eq(404)
    end

    it "with invalid token" do
      post(
        api_v1_post_vote_path(@poll_post.guid),
        params: {
          poll_answer_id: @poll_answer.id,
          access_token:   invalid_token
        }
      )
      expect(response.status).to eq(401)
    end
  end
end
