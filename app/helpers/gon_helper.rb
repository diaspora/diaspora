# frozen_string_literal: true

module GonHelper
  def gon_load_contact(contact)
    Gon.preloads[:contacts] ||= []
    if Gon.preloads[:contacts].none? {|stored_contact| stored_contact[:person][:id] == contact.person_id }
      Gon.preloads[:contacts] << ContactPresenter.new(contact, current_user).full_hash_with_person
    end
  end
end
