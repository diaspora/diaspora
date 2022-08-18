# frozen_string_literal: true

module Notifications
  class ResharedService
    def self.notify(reshare, _)
      return unless reshare.root.present? && reshare.root.author.local?

      actor = reshare.author
      Notifications::Reshared
        .concatenate_or_create(reshare.root.author.owner, reshare.root, actor)
        .try(:email_the_user, reshare, actor)
    end
  end
end
