# frozen_string_literal: true

class ContactRetraction < Retraction
  def self.entity_class
    DiasporaFederation::Entities::Contact
  end

  def self.retraction_data_for(target)
    Diaspora::Federation::Entities.contact(target).to_h
  end

  def self.for(target)
    target.receiving = false
    super
  end

  def public?
    false
  end
end
