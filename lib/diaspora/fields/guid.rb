# frozen_string_literal: true

module Diaspora
  module Fields
    module Guid
      # Creates a after_initialize callback which calls #set_guid
      def self.included(model)
        model.class_eval do
          after_initialize :set_guid
          validates :guid, uniqueness: true
        end
      end

      # @return [String] The model's guid.
      def set_guid
        self.guid = UUID.generate(:compact) if guid.blank?
      end
    end
  end
end
