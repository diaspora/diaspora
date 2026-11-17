# frozen_string_literal: true

module Diaspora
  module Federated
    class ContactRetraction < Retraction
      def self.entity_class
        DiasporaFederation::Entities::Contact
      end

      def self.retraction_data_for(target)
        Diaspora::Federation::Entities.build(target).to_h
      end

      def self.for(target)
        target.receiving = false if target.is_a?(Contact)
        super
      end

      def public?
        false
      end
    end
  end
end
