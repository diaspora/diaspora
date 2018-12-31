# frozen_string_literal: true

module Diaspora
  module MentionsContainer
    extend ActiveSupport::Concern

    included do
      after_create :create_mentions
      has_many :mentions, as: :mentions_container, dependent: :destroy
    end

    def mentioned_people
      if persisted?
        mentions.includes(person: :profile).map(&:person)
      else
        Diaspora::Mentionable.people_from_string(text)
      end
    end

    def add_mention_subscribers?
      public?
    end

    def subscribers
      super.tap {|subscribers|
        subscribers.concat(mentions.map(&:person).select(&:remote?)) if add_mention_subscribers?
      }
    end

    def create_mentions
      Diaspora::Mentionable.people_from_string(text).each do |person|
        mentions.find_or_create_by(person_id: person.id)
      end
    end

    def message
      @message ||= Diaspora::MessageRenderer.new text, mentioned_people: mentioned_people
    end
  end
end
