# frozen_string_literal: true

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
