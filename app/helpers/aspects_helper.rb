#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module AspectsHelper
  def remove_link(aspect)
    if aspect.contacts.size == 0
      link_to I18n.t('aspects.helper.remove'), aspect, :method => :delete, :confirm => I18n.t('aspects.helper.are_you_sure')
    else
      "<span class='grey' title=#{I18n.t('aspects.helper.aspect_not_empty')}>#{I18n.t('aspects.helper.remove')}</span>"
    end
  end

  def add_to_aspect_button(aspect_id, person_id)
    link_to image_tag('icons/monotone_plus_add_round.png'),
      {:controller => 'aspect_memberships',
        :action => 'create',
        :aspect_id => aspect_id,
        :person_id => person_id},
      :remote => true,
      :method => 'post',
      :class => 'add button',
      'data-aspect_id' => aspect_id,
      'data-person_id' => person_id
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
      :class => 'added button',
      'data-aspect_id' => aspect_id,
      'data-person_id' => person_id
  end

  def aspect_membership_button(aspect, contact, person)
    return if person && person.closed_account?
    
    if contact.nil? || !contact.aspect_memberships.detect{ |am| am.aspect_id == aspect.id}
      add_to_aspect_button(aspect.id, person.id)
    else
      remove_from_aspect_button(aspect.id, person.id)
    end
  end
end
