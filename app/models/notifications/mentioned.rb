# frozen_string_literal: true

module Notifications
  module Mentioned
    extend ActiveSupport::Concern

    def linked_object
      target.mentions_container
    end

    module ClassMethods
      def notify(mentionable, recipient_user_ids)
        actor = mentionable.author
        relevant_mentions = filter_mentions(
          mentionable.mentions.local.where.not(person: actor),
          mentionable,
          recipient_user_ids
        )

        relevant_mentions.each do |mention|
          recipient = mention.person.owner
          unless exists?(recipient: recipient, target: mention)
            create_notification(recipient, mention, actor).try(:email_the_user, mention, actor)
          end
        end
      end
    end
  end
end
