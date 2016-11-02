#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Diaspora
  module Relayable
    def self.included(model)
      model.class_eval do
        validates_associated :parent
        validate :author_is_not_ignored

        delegate :public?, to: :parent
        delegate :author, :diaspora_handle, to: :parent, prefix: true
      end
    end

    def author_is_not_ignored
      unless new_record? && parent.present? && parent.author.local? &&
        parent.author.owner.ignored_people.include?(author)
        return
      end

      errors.add(:author_id, "This relayable author is ignored by the post author")
    end

    # @return [Array<Person>]
    def subscribers
      if parent.author.local?
        if author.local?
          parent.subscribers
        else
          parent.subscribers.select(&:remote?).reject {|person| person.pod_id == author.pod_id }
        end
      else
        [parent.author, author]
      end
    end

    # @deprecated This is only needed for pre 0.6 pods
    def sender_for_dispatch
      parent.author.owner if parent.author.local?
    end

    # @abstract
    def parent
      raise NotImplementedError.new('you must override parent in order to enable relayable on this model')
    end
  end
end
