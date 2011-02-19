#/   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module AspectsHelper
  def link_for_aspect(aspect, opts={})
    opts[:params] ||= {}
    params ||= {}
    opts[:params] = opts[:params].merge("a_ids[]" => aspect.id, :created_at => params[:created_at])

    link_to aspect.name, aspects_path( opts[:params] ), opts
  end

  def remove_link(aspect)
    if aspect.contacts.size == 0
      link_to I18n.t('aspects.helper.remove'), aspect, :method => :delete, :confirm => I18n.t('aspects.helper.are_you_sure')
    else
      "<span class='grey' title=#{I18n.t('aspects.helper.aspect_not_empty')}>#{I18n.t('aspects.helper.remove')}</span>"
    end
  end

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

  def contact_or_membership(contact)
    (contact.persisted?) ? 'aspect_memberships' : 'contacts'
  end

  def aspect_membership_button(aspect, contact, person)
    if contact.nil? || !aspect.contacts.include?(contact)
      add_to_aspect_button(aspect.id, person.id, contact_or_membership(contact))
    else
      remove_from_aspect_button(aspect.id, person.id)
    end
  end

  def publisher_description(aspect_count)
    str = "#{t('.share_with')} #{aspect_count} "
    if aspect_count == 1
      str += t('_aspect').downcase
    else
      str += t('_aspects').downcase
    end
    ("<span>#{str}</span>").html_safe
  end
end
