#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module AspectsHelper
  def add_to_aspect_button(aspect_id, person_id)
    link_to content_tag(:div, nil, :class => 'icons-monotone_plus_add_round'),
      { :controller => 'aspect_memberships',
        :action => 'create',
        :format => :json,
        :aspect_id => aspect_id,
        :person_id => person_id
      },
      :method => 'post',
      :class => 'add button',
      'data-aspect_id' => aspect_id,
      'data-person_id' => person_id
  end

  def remove_from_aspect_button(membership_id, aspect_id, person_id)
    link_to content_tag(:div, nil, :class => 'icons-monotone_check_yes'),
      { :controller => "aspect_memberships",
        :action => 'destroy',
        :id => membership_id
      },
      :method => 'delete',
      :class => 'added button',
      'data-membership_id' => membership_id,
      'data-aspect_id' => aspect_id,
      'data-person_id' => person_id
  end

  def aspect_membership_button(aspect, contact, person)
    return if person && person.closed_account?

    membership = contact.aspect_memberships.where(:aspect_id => aspect.id).first
    if contact.nil? || membership.nil?
      add_to_aspect_button(aspect.id, person.id)
    else
      remove_from_aspect_button(membership.id, aspect.id, person.id)
    end
  end
end
