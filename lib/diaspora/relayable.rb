# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Diaspora
  module Relayable
    def self.included(model)
      model.class_eval do
        validates :parent, presence: true
        validates_associated :parent
        validate :author_is_not_ignored

        delegate :public?, to: :parent
        delegate :author, :diaspora_handle, to: :parent, prefix: true
      end
    end

    def root
      @root ||= parent
      @root = @root.parent while @root.is_a?(Relayable)
      @root
    end

    def author_is_not_ignored
      unless new_record? && root.present? && root.author.local? &&
        root.author.owner.ignored_people.include?(author)
        return
      end

      errors.add(:author_id, "This relayable author is ignored by the post author")
    end

    # @return [Array<Person>]
    def subscribers
      if root.author.local?
        if author.local?
          root.subscribers
        else
          root.subscribers.select(&:remote?).reject {|person| person.pod_id == author.pod_id }
        end
      else
        [root.author, author]
      end
    end

    def sender_for_dispatch
      root.author.owner if root.author.local?
    end

    # @abstract
    def parent
      raise NotImplementedError.new('you must override parent in order to enable relayable on this model')
    end
  end
end
