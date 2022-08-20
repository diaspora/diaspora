# frozen_string_literal: true

module Notifications
  class MentionedInPostService
    def self.model
      Notifications::MentionedInPost
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

        NotificationService.new(recipient).mail(
          Workers::Mail::Mentioned,
          recipient.id,
          actor.id,
          mention.id
        )
      end
    end

    def self.filter_mentions(mentions, mentionable, recipient_user_ids)
      return mentions if mentionable.public

      mentions.where(person: Person.where(owner_id: recipient_user_ids).ids)
    end
  end
end
