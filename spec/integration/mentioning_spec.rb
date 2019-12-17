# frozen_string_literal: true

module MentioningSpecHelpers
  def notifications_about_mentioning(user, object)
    table = object.class.table_name

    if object.is_a?(StatusMessage)
      klass = Notifications::MentionedInPost
    elsif object.is_a?(Comment)
      klass = Notifications::MentionedInComment
    end

    klass
      .where(recipient_id: user.id)
      .joins("LEFT OUTER JOIN mentions ON notifications.target_id = mentions.id AND "\
             "notifications.target_type = 'Mention'")
      .joins("LEFT OUTER JOIN #{table} ON mentions_container_id = #{table}.id AND "\
             "mentions_container_type = '#{object.class.base_class}'").where(table.to_sym => {id: object.id})
  end

  def mention_container_path(object)
    object.is_a?(Post) ? post_path(object) : post_path(object.parent, anchor: object.guid)
  end

  def mentioning_mail_notification(user, object)
    ActionMailer::Base.deliveries.select {|delivery|
      delivery.to.include?(user.email) &&
        delivery.subject.include?(I18n.t("notifier.mentioned.subject", name: "")) &&
        delivery.body.parts[0].body.include?(mention_container_path(object))
    }
  end

  def also_commented_mail_notification(user, post)
    ActionMailer::Base.deliveries.select {|delivery|
      delivery.to.include?(user.email) &&
        delivery.subject.include?(I18n.t("notifier.also_commented.limited_subject")) &&
        delivery.body.parts[0].body.include?(post_path(post))
    }
  end

  def stream_for(user)
    stream = Stream::Multi.new(user)
    stream.posts
  end

  def mention_stream_for(user)
    stream = Stream::Mention.new(user)
    stream.posts
  end

  def post_status_message(mentioned_user, aspects=nil)
    aspects = user1.aspects.first.id.to_s if aspects.nil?
    sign_in user1
    status_msg = nil
    inlined_jobs do
      post "/status_messages.json", params: {
        status_message: {text: text_mentioning(mentioned_user)},
        aspect_ids:     aspects
      }
      status_msg = StatusMessage.find(JSON.parse(response.body)["id"])
    end
    status_msg
  end

  def receive_each(entity, recipients)
    inlined_jobs do
      recipients.each do |recipient|
        DiasporaFederation.callbacks.trigger(:receive_entity, entity, entity.author, recipient.id)
      end
    end
  end

  def find_private_message(guid)
    StatusMessage.find_by(guid: guid).tap do |status_msg|
      expect(status_msg).not_to be_nil
      expect(status_msg.public?).to be false
    end
  end

  def receive_status_message_via_federation(text, *recipients)
    entity = Fabricate(
      :status_message_entity,
      author: remote_raphael.diaspora_handle,
      text:   text,
      public: false
    )

    expect {
      receive_each(entity, recipients)
    }.to change(Post, :count).by(1).and change(ShareVisibility, :count).by(recipients.count)

    find_private_message(entity.guid)
  end

  def receive_comment_via_federation(text, parent)
    entity = build_relayable_federation_entity(
      :comment,
      parent_guid: parent.guid,
      author:      remote_raphael.diaspora_handle,
      parent:      Diaspora::Federation::Entities.related_entity(parent),
      text:        text
    )

    receive_each(entity, [parent.author.owner])

    Comment.find_by(guid: entity.guid)
  end
end

describe "mentioning", type: :request do
  include MentioningSpecHelpers

  RSpec::Matchers.define :be_mentioned_in do |object|
    include Rails.application.routes.url_helpers

    def user_notified?(user, object)
      notifications_about_mentioning(user, object).any? && mentioning_mail_notification(user, object).any?
    end

    match do |user|
      object.message.markdownified.include?(person_path(id: user.person.guid)) && user_notified?(user, object)
    end

    match_when_negated do |user|
      !user_notified?(user, object)
    end
  end

  RSpec::Matchers.define :be_in_streams_of do |user|
    match do |status_message|
      stream_for(user).map(&:id).include?(status_message.id) &&
        mention_stream_for(user).map(&:id).include?(status_message.id)
    end

    match_when_negated do |status_message|
      !stream_for(user).map(&:id).include?(status_message.id) &&
        !mention_stream_for(user).map(&:id).include?(status_message.id)
    end
  end

  let(:user1) { FactoryGirl.create(:user_with_aspect) }
  let(:user2) { FactoryGirl.create(:user_with_aspect, friends: [user1, user3]) }
  let(:user3) { FactoryGirl.create(:user_with_aspect) }

  # see: https://github.com/diaspora/diaspora/issues/4160
  it "only mentions people that are in the target aspect" do
    status_msg = nil
    expect {
      status_msg = post_status_message(user3)
    }.to change(Post, :count).by(1).and change(AspectVisibility, :count).by(1)

    expect(status_msg).not_to be_nil
    expect(status_msg.public?).to be false
    expect(status_msg.text).to include(user3.name)

    expect(user3).not_to be_mentioned_in(status_msg)
    expect(status_msg).not_to be_in_streams_of(user3)
  end

  context "in private post via federation" do
    let(:status_msg) {
      receive_status_message_via_federation(text_mentioning(user2, user3), user3)
    }

    it "receiver is mentioned in status message" do
      expect(user3).to be_mentioned_in(status_msg)
    end

    it "receiver can see status message in streams" do
      expect(status_msg).to be_in_streams_of(user3)
    end

    it "non-receiver is not mentioned in status message" do
      expect(user2).not_to be_mentioned_in(status_msg)
    end

    it "non-receiver can't see status message in streams" do
      expect(status_msg).not_to be_in_streams_of(user2)
    end
  end

  context "in private post via federation with multiple recipients" do
    let(:status_msg) {
      receive_status_message_via_federation(text_mentioning(user3, user2), user3, user2)
    }

    it "mentions all recipients in the status message" do
      [user2, user3].each do |user|
        expect(user).to be_mentioned_in(status_msg)
      end
    end

    it "all recipients can see status message in streams" do
      [user2, user3].each do |user|
        expect(status_msg).to be_in_streams_of(user)
      end
    end
  end

  it "mentions people in public posts" do
    status_msg = nil
    expect {
      status_msg = post_status_message(user3, "public")
    }.to change(Post, :count).by(1)

    expect(status_msg).not_to be_nil
    expect(status_msg.public?).to be true
    expect(status_msg.text).to include(user3.diaspora_handle)

    expect(user3).to be_mentioned_in(status_msg)
    expect(status_msg).to be_in_streams_of(user3)
  end

  it "mentions people that are in the target aspect" do
    status_msg = nil
    expect {
      status_msg = post_status_message(user2)
    }.to change(Post, :count).by(1).and change(AspectVisibility, :count).by(1)

    expect(status_msg).not_to be_nil
    expect(status_msg.public?).to be false
    expect(status_msg.text).to include(user2.diaspora_handle)

    expect(user2).to be_mentioned_in(status_msg)
    expect(status_msg).to be_in_streams_of(user2)
  end

  context "in comments" do
    let(:author) { FactoryGirl.create(:user_with_aspect) }

    shared_context "commenter is author" do
      let(:commenter) { author }
    end

    shared_context "commenter is author's friend" do
      let(:commenter) { FactoryGirl.create(:user_with_aspect, friends: [author]) }
    end

    shared_context "commenter is not author's friend" do
      let(:commenter) { FactoryGirl.create(:user) }
    end

    shared_context "mentioned user is author" do
      let(:mentioned_user) { author }
    end

    shared_context "mentioned user is author's friend" do
      let(:mentioned_user) { FactoryGirl.create(:user_with_aspect, friends: [author]) }
    end

    shared_context "mentioned user is not author's friend" do
      let(:mentioned_user) { FactoryGirl.create(:user) }
    end

    context "with public post" do
      let(:status_msg) { FactoryGirl.create(:status_message, author: author.person, public: true) }

      [
        ["commenter is author's friend", "mentioned user is not author's friend"],
        ["commenter is author's friend", "mentioned user is author"],
        ["commenter is not author's friend", "mentioned user is author's friend"],
        ["commenter is not author's friend", "mentioned user is not author's friend"],
        ["commenter is author", "mentioned user is author's friend"],
        ["commenter is author", "mentioned user is not author's friend"]
      ].each do |commenters_context, mentioned_context|
        context "when #{commenters_context} and #{mentioned_context}" do
          include_context commenters_context
          include_context mentioned_context

          let(:comment) {
            inlined_jobs do
              commenter.comment!(status_msg, text_mentioning(mentioned_user))
            end
          }

          subject { mentioned_user }
          it { is_expected.to be_mentioned_in(comment) }
        end
      end

      context "when comment is received via federation" do
        context "when mentioned user is remote" do
          it "relays the comment to the mentioned user" do
            mentioned_person = FactoryGirl.create(:person)
            expect_any_instance_of(Diaspora::Federation::Dispatcher::Public)
              .to receive(:deliver_to_remote).with([mentioned_person])

            receive_comment_via_federation(text_mentioning(mentioned_person), status_msg)
          end
        end
      end
    end

    context "with private post" do
      [
        ["commenter is author's friend", "mentioned user is author's friend"],
        ["commenter is author", "mentioned user is author's friend"],
        ["commenter is author's friend", "mentioned user is author"]
      ].each do |commenters_context, mentioned_context|
        context "when #{commenters_context} and #{mentioned_context}" do
          include_context commenters_context
          include_context mentioned_context

          let(:parent) { FactoryGirl.create(:status_message_in_aspect, author: author.person) }
          let(:comment) {
            inlined_jobs do
              commenter.comment!(parent, text_mentioning(mentioned_user))
            end
          }

          before do
            mentioned_user.like!(parent)
          end

          subject { mentioned_user }
          it { is_expected.to be_mentioned_in(comment) }
        end
      end

      context "when comment is received via federation" do
        let(:parent) { FactoryGirl.create(:status_message_in_aspect, author: user2.person) }

        before do
          user3.like!(parent)
          user1.like!(parent)
        end

        let(:comment_text) { text_mentioning(user2, user3, user1) }
        let(:comment) { receive_comment_via_federation(comment_text, parent) }

        it "mentions all the recepients" do
          [user1, user2, user3].each do |user|
            expect(user).to be_mentioned_in(comment)
          end
        end

        context "with only post author mentioned" do
          let(:post_author) { parent.author.owner }
          let(:comment_text) { text_mentioning(post_author) }

          it "makes only one notification for each recipient" do
            expect {
              comment
            }.to change { Notifications::MentionedInComment.for(post_author).count }.by(1)
              .and change { Notifications::AlsoCommented.for(user1).count }.by(1)
              .and change { Notifications::AlsoCommented.for(user3).count }.by(1)

            expect(mentioning_mail_notification(post_author, comment).count).to eq(1)

            [user1, user3].each do |user|
              expect(also_commented_mail_notification(user, parent).count).to eq(1)
            end
          end
        end
      end

      context "commenter can't mention a non-participant" do
        let(:status_msg) { FactoryGirl.create(:status_message_in_aspect, author: author.person) }

        [
          ["commenter is author's friend", "mentioned user is not author's friend"],
          ["commenter is not author's friend", "mentioned user is author's friend"],
          ["commenter is not author's friend", "mentioned user is not author's friend"],
          ["commenter is author", "mentioned user is author's friend"],
          ["commenter is author", "mentioned user is not author's friend"]
        ].each do |commenters_context, mentioned_context|
          context "when #{commenters_context} and #{mentioned_context}" do
            include_context commenters_context
            include_context mentioned_context

            let(:comment) {
              inlined_jobs do
                commenter.comment!(status_msg, text_mentioning(mentioned_user))
              end
            }

            subject { mentioned_user }
            it { is_expected.not_to be_mentioned_in(comment) }
          end
        end
      end

      it "only creates one notification for the mentioned person, when mentioned person commented twice before" do
        parent = FactoryGirl.create(:status_message_in_aspect, author: author.person)
        mentioned_user = FactoryGirl.create(:user_with_aspect, friends: [author])
        mentioned_user.comment!(parent, "test comment 1")
        mentioned_user.comment!(parent, "test comment 2")
        comment = inlined_jobs do
          author.comment!(parent, text_mentioning(mentioned_user))
        end

        expect(notifications_about_mentioning(mentioned_user, comment).count).to eq(1)
      end
    end
  end
end
