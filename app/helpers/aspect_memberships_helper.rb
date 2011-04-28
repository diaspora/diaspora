module AspectMembershipsHelper
  def add_to_aspect_button(aspect_id, person_id, kontroller)
    link_to image_tag('icons/monotone_plus_add_round.png'),
      {:controller => kontroller,
        :action => 'create',
        :aspect_id => aspect_id,
        :person_id => person_id},
      :remote => true,
      :method => 'post',
      :class => 'add button'
  end

  def remove_from_aspect_button(aspect_id, person_id)
    link_to image_tag('icons/monotone_check_yes.png'),
      {:controller => "aspect_memberships",
        :action => 'destroy',
        :id => 42,
        :aspect_id => aspect_id,
        :person_id => person_id},
      :remote => true,
      :method => 'delete',
      :class => 'added button'
  end

  def aspect_membership_button(aspect, contact, person)
    if contact.nil? || !aspect.contacts.include?(contact)
      add_to_aspect_button(aspect.id, person.id, contact_or_membership(contact))
    else
      remove_from_aspect_button(aspect.id, person.id)
    end
  end

  def contact_or_membership(contact)
    (contact.persisted?) ? 'aspect_memberships' : 'contacts'
  end
end
