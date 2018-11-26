# frozen_sTring_literal: true

require "spec_helper"

describe Api::V1::PostinteractionsController do
  let(:auth) { FactoryGirl.create(:auth_with_read_and_write) }
  let!(:access_token) { auth.create_access_token.to_s }
  let(:auth_read_only) { FactoryGirl.create(:auth_with_read) }
  let!(:access_token_read_only) { auth_read_only.create_access_token.to_s }

  before do
    @status = alice.post(
      :status_message,
      text:   "hello @{#{bob.diaspora_handle}} and @{#{eve.diaspora_handle}}from Alice!",
      public: true,
      to:     "all"
    )
  end

  describe "#subscribe" do
    context "succeeds" do
      it "with proper guid and access token" do
        post(
          api_v1_post_subscribe_path(@status.guid),
          params: {
            access_token: access_token
          }
        )
        expect(response.status).to eq(204)
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

      it "with read only token" do
        post(
          api_v1_post_subscribe_path(@status.guid),
          params: {
            access_token: access_token_read_only
          }
        )
        expect(response.status).to eq(403)
      end

      it "with invalid token" do
        post(
          api_v1_post_subscribe_path(@status.guid),
          params: {
            access_token: "999_999_999"
          }
        )
        expect(response.status).to eq(401)
      end
    end
  end

  describe "#hide" do
    context "succeeds" do
      it "with proper guid and access token" do
        post(
          api_v1_post_hide_path(@status.guid),
          params: {
            access_token: access_token
          }
        )
        expect(response.status).to eq(204)
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

      it "with read only token" do
        post(
          api_v1_post_hide_path(@status.guid),
          params: {
            access_token: access_token_read_only
          }
        )
        expect(response.status).to eq(403)
      end

      it "with invalid token" do
        post(
          api_v1_post_hide_path(@status.guid),
          params: {
            access_token: "999_999_999"
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
        post(
          api_v1_post_mute_path(@status.guid),
          params: {
            access_token: access_token
          }
        )
        expect(response.status).to eq(204)
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

      it "with read only token" do
        post(
          api_v1_post_mute_path(@status.guid),
          params: {
            access_token: access_token_read_only
          }
        )
        expect(response.status).to eq(403)
      end

      it "with invalid token" do
        post(
          api_v1_post_mute_path(@status.guid),
          params: {
            access_token: "999_999_999"
          }
        )
        expect(response.status).to eq(401)
      end
    end
  end

  describe "#report" do
    context "succeeds" do
      it "with proper guid and access token" do
        post(
          api_v1_post_report_path(@status.guid),
          params: {
            reason:       "My reason",
            access_token: access_token
          }
        )
        expect(response.status).to eq(204)
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

      it "with read only token" do
        post(
          api_v1_post_report_path(@status.guid),
          params: {
            reason:       "My reason",
            access_token: access_token_read_only
          }
        )
        expect(response.status).to eq(403)
      end

      it "with invalid token" do
        post(
          api_v1_post_report_path(@status.guid),
          params: {
            reason:       "My reason",
            access_token: "999_999_999"
          }
        )
        expect(response.status).to eq(401)
      end
    end
  end
end
