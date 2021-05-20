# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Workers
  # It's based on spam_account script https://github.com/SuperTux88/diaspora/blob/nerdpol_ch/script/nerdpol.ch/diaspora_spam.rb
  class WipeAccount < Base
    sidekiq_options queue: :high

    # person should already be closed
    def perform(diaspora_handle)
      local_persons, remote_persons = Person.where(diaspora_handle: diaspora_handle).partition(&:local?)
      retract_local_comments(local_persons)
      retract_remote_comments(remote_persons)

      delete_account(local_persons)
      delete_account(remote_persons)
    end

    private

    def retract_local_comments(local_persons)
      local_persons.each do |spammer|
        Comment.where(author_id: spammer.id).each do |comment|
          spammer.owner.retract(comment)
        end
      end
    end

    def retract_remote_comments(remote_persons)
      Comment.where(author_id: remote_persons.map(&:id)).each do |comment|
        post_author = comment.parent.author
        if post_author.local? && (retract_for.include?(post_author.owner.username) || retract_for.empty?)
          post_author.owner.retract(comment)
        else
          comment.destroy
        end
      end
    end

    def delete_account(persons)
      persons.each do |spammer|
        AccountDeletion.create!(person: spammer) unless AccountDeletion.exists?(person: spammer)
      end
    end
  end
end
