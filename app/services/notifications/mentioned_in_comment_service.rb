# frozen_string_literal: true

module Notifications
  class MentionedInCommentService
    def self.model
      Notifications::MentionedInComment
    end

    def self.notify(mentionable, recipient_user_ids)
      actor = mentionable.author
      relevant_mentions = filter_mentions(
        mentionable.mentions.local.where.not(person: actor),
        mentionable,
        recipient_user_ids
      )

      relevant_mentions.each do |mention|
        recipient = mention.person.owner
        next if model.exists?(recipient: recipient, target: mention)

        model
          .create_notification(recipient, mention, actor)
          .try(:email_the_user, mention, actor)
      end
    end

    def self.filter_mentions(mentions, mentionable, _recipient_user_ids)
      mentions.includes(:person).merge(Person.allowed_to_be_mentioned_in_a_comment_to(mentionable.parent))
    end
  end
end
