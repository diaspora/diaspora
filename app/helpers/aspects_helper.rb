#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module AspectsHelper
  def next_page_path
    aspects_path(:max_time => @posts.last.send(session[:sort_order].to_sym).to_i, :a_ids => params[:a_ids])
  end

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
      add_to_aspect_button(aspect.id, person.id)
    else
      remove_from_aspect_button(aspect.id, person.id)
    end
  end
end
