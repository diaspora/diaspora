# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

describe Report, type: :mailer do
  describe "#make_notification" do
    before do
      @reported_user = bob
      @post = @reported_user.post(:status_message, text: "hello", to: @reported_user.aspects.first.id)
      @comment = @reported_user.comment!(@post, "welcome")
      @post_report = @reported_user.reports.create(
        item_id: @post.id, item_type: "Post",
        text: "offensive content"
      )
      @comment_report = @reported_user.reports.create(
        item_id: @comment.id, item_type: "Comment",
        text: "offensive comment"
      )
      @remote = FactoryGirl.create(:person, diaspora_handle: "remote@remote.net")
      @user = FactoryGirl.create(:user_with_aspect, username: "local", language: "de")
      @user2 = FactoryGirl.create(:user_with_aspect, username: "locally")
      Role.add_admin(@user.person)
      Role.add_moderator(@user2.person)
    end

    it "should deliver successfully" do
      expect {
        ReportMailer.new_report(@post_report.id).each(&:deliver_now)
      }.to_not raise_error
    end

    it "should be added to the delivery queue" do
      expect {
        ReportMailer.new_report(@post_report.id).each(&:deliver_now)
      }.to change(ActionMailer::Base.deliveries, :size).by(2)
    end

    it "should include correct recipient" do
      ReportMailer.new_report(@post_report.id).each(&:deliver_now)
      expect(ActionMailer::Base.deliveries[0].to[0]).to include(@user.email)
      expect(ActionMailer::Base.deliveries[1].to[0]).to include(@user2.email)
    end

    it "FROM: header should be the pod name + default sender address" do
      ReportMailer.new_report(@post_report.id).each(&:deliver_now)
      pod_name = AppConfig.settings.pod_name
      expect(ReportMailer.default[:from].to_s).to eq("\"#{pod_name}\" <#{AppConfig.mail.sender_address}>")
    end

    it "should send mail in recipent's prefered language" do
      ReportMailer.new_report(@post_report.id).each(&:deliver_now)
      expect(ActionMailer::Base.deliveries[0].subject).to match("Ein neuer post wurde als anstößig markiert")
      expect(ActionMailer::Base.deliveries[1].subject).to match("A new post was marked as offensive")
    end

    it "should find correct post translation" do
      ReportMailer.new_report(@post_report.id).each(&:deliver_now)
      expect(ActionMailer::Base.deliveries[0].subject).not_to match("translation missing")
    end

    it "should find correct comment translation" do
      ReportMailer.new_report(@comment_report.id).each(&:deliver_now)
      expect(ActionMailer::Base.deliveries[0].subject).not_to match("translation missing")
    end
  end
end
