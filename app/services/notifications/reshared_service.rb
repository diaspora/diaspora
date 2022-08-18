# frozen_string_literal: true

module Notifications
  class ResharedService
    def self.notify(reshare, _)
      return unless reshare.root.present? && reshare.root.author.local?

      actor = reshare.author
      recipient = reshare.root.author.owner
      Notifications::Reshared
        .concatenate_or_create(recipient, reshare.root, actor)

      recipient.mail(
        Workers::Mail::Reshared,
        recipient.id,
        actor.id,
        reshare.id
      )
    end
  end
end
