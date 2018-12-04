# frozen_string_literal: true

require "spec_helper"

describe Api::V1::NotificationsController do
  let(:auth) { FactoryGirl.create(:auth_with_read_and_write) }
  let(:auth_read_only) { FactoryGirl.create(:auth_with_read) }
  let!(:access_token) { auth.create_access_token.to_s }
  let!(:access_token_read_only) { auth_read_only.create_access_token.to_s }

  before do
    @post = auth.user.post(
      :status_message,
      text:   "This is a status message",
      public: true,
      to:     "all"
    )
    @notification = FactoryGirl.create(:notification, recipient: auth.user, target: @post)
  end

  describe "#index" do
    context "success" do
      it "with proper credentials and no flags" do
        get(
          api_v1_notifications_path,
          params: {access_token: access_token}
        )
        expect(response.status).to eq(200)
        notification = JSON.parse(response.body)
        expect(notification.length).to eq(1)
        confirm_notification_format(notification[0], @notification, "also_commented", nil)
      end

      it "with proper credentials and unread only" do
        get(
          api_v1_notifications_path,
          params: {only_unread: true, access_token: access_token}
        )
        expect(response.status).to eq(200)
        notification = JSON.parse(response.body)
        expect(notification.length).to eq(1)
        @notification.set_read_state(true)
        get(
          api_v1_notifications_path,
          params: {only_unread: true, access_token: access_token}
        )
        expect(response.status).to eq(200)
        notification = JSON.parse(response.body)
        expect(notification.length).to eq(0)
      end

      it "with proper credentials and after certain date" do
        get(
          api_v1_notifications_path,
          params: {only_after: (Date.current - 1.day).iso8601, access_token: access_token}
        )
        expect(response.status).to eq(200)
        notification = JSON.parse(response.body)
        expect(notification.length).to eq(1)
        @notification.set_read_state(true)
        get(
          api_v1_notifications_path,
          params: {only_after: (Date.current + 1.day).iso8601, access_token: access_token}
        )
        expect(response.status).to eq(200)
        notification = JSON.parse(response.body)
        expect(notification.length).to eq(0)
      end
    end

    context "fails" do
      it "with bad date format" do
        get(
          api_v1_notifications_path,
          params: {only_after: "January 1, 2018", access_token: access_token}
        )
        expect(response.status).to eq(422)
        expect(response.body).to eq(I18n.t("api.endpoint_errors.notifications.cant_process"))
      end

      it "with improper credentials" do
        get(
          api_v1_notifications_path,
          params: {access_token: "999_999_999"}
        )
        expect(response.status).to eq(401)
      end
    end
  end

  describe "#show" do
    context "success" do
      it "with proper credentials and flags" do
        get(
          api_v1_notification_path(@notification.guid),
          params: {access_token: access_token}
        )
        expect(response.status).to eq(200)
        notification = JSON.parse(response.body)
        confirm_notification_format(notification, @notification, "also_commented", @post)
      end
    end

    context "fails" do
      it "with proper invalid GUID" do
        get(
          api_v1_notification_path("999_999_999"),
          params: {access_token: access_token}
        )
        expect(response.status).to eq(404)
        expect(response.body).to eq(I18n.t("api.endpoint_errors.notifications.not_found"))
      end

      it "on someone else's notification" do
        alice_post = alice.post(
          :status_message,
          text:   "This is a status message",
          public: true,
          to:     "all"
        )
        alice_notification = FactoryGirl.create(:notification, recipient: alice, target: alice_post)

        get(
          api_v1_notification_path(alice_notification.guid),
          params: {access_token: access_token}
        )
        expect(response.status).to eq(404)
        expect(response.body).to eq(I18n.t("api.endpoint_errors.notifications.not_found"))
      end

      it "with improper credentials" do
        get(
          api_v1_notification_path(@notification.guid),
          params: {access_token: "999_999_999"}
        )
        expect(response.status).to eq(401)
      end
    end
  end

  describe "#update" do
    context "success" do
      it "with proper credentials and flags" do
        patch(
          api_v1_notification_path(@notification.guid),
          params: {read: true, access_token: access_token}
        )
        expect(response.status).to eq(204)
        expect(@notification.reload.unread).to be(false)
        patch(
          api_v1_notification_path(@notification.guid),
          params: {read: false, access_token: access_token}
        )
        expect(response.status).to eq(204)
        expect(@notification.reload.unread).to be(true)
      end
    end

    context "fails" do
      it "with proper invalid GUID" do
        patch(
          api_v1_notification_path("999_999_999"),
          params: {access_token: access_token}
        )
        expect(response.status).to eq(422)
        expect(response.body).to eq(I18n.t("api.endpoint_errors.notifications.cant_process"))
      end

      it "with proper missing read field" do
        patch(
          api_v1_notification_path(@notification.guid),
          params: {access_token: access_token}
        )
        expect(response.status).to eq(422)
        expect(response.body).to eq(I18n.t("api.endpoint_errors.notifications.cant_process"))
      end

      it "with read only credentials" do
        patch(
          api_v1_notification_path(@notification.guid),
          params: {access_token: access_token_read_only}
        )
        expect(response.status).to eq(403)
      end

      it "with improper credentials" do
        patch(
          api_v1_notification_path(@notification.guid),
          params: {access_token: "999_999_999"}
        )
        expect(response.status).to eq(401)
      end
    end
  end

  private

  # rubocop:disable Metrics/AbcSize
  def confirm_notification_format(notification, ref_notification, expected_type, target)
    expect(notification["guid"]).to eq(ref_notification.guid)
    expect(notification["type"]).to eq(expected_type) if expected_type
    expect(notification["read"]).to eq(!ref_notification.unread)
    expect(notification.has_key?("created_at")).to be_truthy
    expect(notification["target"]["guid"]).to eq(target.guid) if target
    expect(notification["event_creators"].length).to eq(ref_notification.actors.length)
  end
  # rubocop:enable Metrics/AbcSize
end
