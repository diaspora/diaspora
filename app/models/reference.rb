# frozen_string_literal: true

class Reference < ApplicationRecord
  belongs_to :source, polymorphic: true
  belongs_to :target, polymorphic: true
  validates :target_id, uniqueness: {scope: %i[target_type source_id source_type]}

  module Source
    extend ActiveSupport::Concern

    included do
      after_create :create_references
      has_many :references, as: :source, dependent: :destroy
    end

    def create_references
      text&.scan(DiasporaFederation::Federation::DiasporaUrlParser::DIASPORA_URL_REGEX)&.each do |author, type, guid|
        add_reference(author, type, guid)
      end
    end

    private

    def add_reference(author, type, guid)
      entity = Diaspora::EntityFinder.new(type, guid).find
      references.find_or_create_by(target: entity) if entity&.diaspora_handle == author
    rescue => e # rubocop:disable Lint/RescueWithoutErrorClass
      logger.warn "ignoring invalid diaspora-url: diaspora://#{author}/#{type}/#{guid}: #{e.class}: #{e.message}"
    end
  end

  module Target
    extend ActiveSupport::Concern

    included do
      has_many :referenced_by, as: :target, class_name: "Reference", dependent: :destroy
    end
  end
end
