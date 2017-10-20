# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

describe NotificationsController, :type => :controller do
  before do
    sign_in alice, scope: :user
  end

  describe '#update' do
    it 'marks a notification as read if it gets no other information' do
      note = FactoryGirl.create(:notification)
      expect(Notification).to receive(:where).and_return([note])
      expect(note).to receive(:set_read_state).with(true)
      get :update, params: {id: note.id}, format: :json
    end

    it 'marks a notification as read if it is told to' do
      note = FactoryGirl.create(:notification)
      expect(Notification).to receive(:where).and_return([note])
      expect(note).to receive(:set_read_state).with(true)
      get :update, params: {id: note.id, set_unread: "false"}, format: :json
    end

    it 'marks a notification as unread if it is told to' do
      note = FactoryGirl.create(:notification)
      expect(Notification).to receive(:where).and_return([note])
      expect(note).to receive(:set_read_state).with(false)
      get :update, params: {id: note.id, set_unread: "true"}, format: :json
    end

    it "marks a notification as unread without timestamping" do
      note = Timecop.travel(1.hour.ago) do
        FactoryGirl.create(:notification, recipient: alice, unread: false)
      end

      get :update, params: {id: note.id, set_unread: "true"}, format: :json
      expect(response).to be_success

      updated_note = Notification.find(note.id)
      expect(updated_note.unread).to eq(true)
      expect(updated_note.updated_at.iso8601).to eq(note.updated_at.iso8601)
    end

    it 'only lets you read your own notifications' do
      user2 = bob

      FactoryGirl.create(:notification, :recipient => alice)
      note = FactoryGirl.create(:notification, :recipient => user2)

      get :update, params: {id: note.id, set_unread: "false"}, format: :json

      expect(Notification.find(note.id).unread).to eq(true)
    end
  end

  describe '#index' do
    before do
      @post = FactoryGirl.create(:status_message)
      @notification = FactoryGirl.create(:notification, recipient: alice, target: @post)
    end

    it 'succeeds' do
      get :index
      expect(response).to be_success
      expect(assigns[:notifications].count).to eq(1)
    end

    it "succeeds for notification dropdown" do
      Timecop.travel(6.seconds.ago) do
        @notification.touch
      end
      get :index, format: :json
      expect(response).to be_success
      response_json = JSON.parse(response.body)
      note_html = Nokogiri::HTML(response_json["notification_list"][0]["also_commented"]["note_html"])
      timeago_content = note_html.css("time")[0]["data-time-ago"]
      expect(response_json["unread_count"]).to be(1)
      expect(response_json["unread_count_by_type"]).to eq(
        "also_commented"       => 1,
        "comment_on_post"      => 0,
        "liked"                => 0,
        "mentioned"            => 0,
        "mentioned_in_comment" => 0,
        "reshared"             => 0,
        "started_sharing"      => 0
      )
      expect(timeago_content).to include(@notification.updated_at.iso8601)
      expect(response.body).to match(/note_html/)
    end

    it 'succeeds on mobile' do
      get :index, format: :mobile
      expect(response).to be_success
    end

    it 'paginates the notifications' do
      25.times { FactoryGirl.create(:notification, :recipient => alice, :target => @post) }
      get :index
      expect(assigns[:notifications].count).to eq(25)
      get :index, params: {page: 2}
      expect(assigns[:notifications].count).to eq(1)
    end

    it "supports a limit per_page parameter" do
      2.times { FactoryGirl.create(:notification, :recipient => alice, :target => @post) }
      get :index, params: {per_page: 2}
      expect(assigns[:notifications].count).to eq(2)
    end

    describe "special case for start sharing notifications" do
      it "should not provide a contacts menu for standard notifications" do
        FactoryGirl.create(:notification, :recipient => alice, :target => @post)
        get :index, params: {per_page: 5}
        expect(Nokogiri(response.body).css('.aspect_membership')).to be_empty
      end

      it "should provide a contacts menu for start sharing notifications" do
        eve.share_with(alice.person, eve.aspects.first)
        get :index, params: {per_page: 5}

        expect(Nokogiri(response.body).css(".aspect-membership-dropdown")).not_to be_empty
      end

      it 'succeeds on mobile' do
        eve.share_with(alice.person, eve.aspects.first)
        get :index, format: :mobile
        expect(response).to be_success
      end
    end

    describe "filter notifications" do
      it "supports filtering by notification type" do
        FactoryGirl.create(:notification, :recipient => alice, :type => "Notifications::StartedSharing")
        get :index, params: {type: "started_sharing"}
        expect(assigns[:notifications].count).to eq(1)
      end

      it "supports filtering by read/unread" do
        FactoryGirl.create(:notification, :recipient => alice, :target => @post)
        get :read_all
        FactoryGirl.create(:notification, :recipient => alice, :target => @post)
        get :index, params: {show: "unread"}
        expect(assigns[:notifications].count).to eq(1)
      end
    end

    context "after deleting a person" do
      before do
        user = FactoryGirl.create(:user_with_aspect)
        user.share_with(alice.person, user.aspects.first)
        user.person.delete
      end

      it "succeeds" do
        get :index
        expect(response).to be_success
      end

      it "succeeds on mobile" do
        get :index, format: :mobile
        expect(response).to be_success
      end
    end
  end

  describe "#read_all" do
    let(:post) { FactoryGirl.create(:status_message) }

    it "marks all notifications as read" do
      request.env["HTTP_REFERER"] = "I wish I were spelled right"
      FactoryGirl.create(:notification, recipient: alice, target: post)
      FactoryGirl.create(:notification, recipient: alice, target: post)

      expect(Notification.where(unread: true).count).to eq(2)
      get :read_all
      expect(Notification.where(unread: true).count).to eq(0)
    end

    it "marks all notifications in the current filter as read" do
      request.env["HTTP_REFERER"] = "I wish I were spelled right"
      FactoryGirl.create(:notification, recipient: alice, target: post)
      FactoryGirl.create(:notification, recipient: alice, type: "Notifications::StartedSharing")
      expect(Notification.where(unread: true).count).to eq(2)
      get :read_all, params: {type: "started_sharing"}
      expect(Notification.where(unread: true).count).to eq(1)
    end

    it "should redirect back in the html version if it has > 0 notifications" do
      FactoryGirl.create(:notification, recipient: alice, type: "Notifications::StartedSharing")
      get :read_all, params: {type: "liked"}, format: :html
      expect(response).to redirect_to(notifications_path)
    end

    it "should redirect back in the mobile version if it has > 0 notifications" do
      FactoryGirl.create(:notification, recipient: alice, type: "Notifications::StartedSharing")
      get :read_all, params: {type: "liked"}, format: :mobile
      expect(response).to redirect_to(notifications_path)
    end

    it "should redirect to stream in the html version if it has 0 notifications" do
      FactoryGirl.create(:notification, recipient: alice, type: "Notifications::StartedSharing")
      get :read_all, params: {type: "started_sharing"}, format: :html
      expect(response).to redirect_to(stream_path)
    end

    it "should redirect back in the mobile version if it has 0 notifications" do
      FactoryGirl.create(:notification, recipient: alice, type: "Notifications::StartedSharing")
      get :read_all, params: {type: "started_sharing"}, format: :mobile
      expect(response).to redirect_to(stream_path)
    end

    it "should return a dummy value in the json version" do
      FactoryGirl.create(:notification, recipient: alice, target: post)
      get :read_all, format: :json
      expect(response).not_to be_redirect
    end
  end
end
