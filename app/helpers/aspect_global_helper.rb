#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module AspectGlobalHelper
  def aspect_membership_dropdown(contact, person, hang)
    aspect_membership_ids = {}

    selected_aspects = all_aspects.select{|aspect| contact.in_aspect?(aspect)}
    selected_aspects.each do |a|
      record = a.aspect_memberships.find { |am| am.contact_id == contact.id }
      aspect_membership_ids[a.id] = record.id
    end

    button_class = selected_aspects.size > 0 ? "btn-success" : "btn-default"

    render "aspect_memberships/aspect_membership_dropdown",
      :selected_aspects => selected_aspects,
      :aspect_membership_ids => aspect_membership_ids,
      :person => person,
      :hang => hang,
      :button_class => button_class
  end

  def aspect_options_for_select(aspects)
    options = {}
    aspects.each do |aspect|
      options[aspect.to_s] = aspect.id
    end
    options
  end

  def publisher_aspects_for(stream=nil)
    if stream
      aspects = stream.aspects
      aspect = stream.aspect
      aspect_ids = stream.aspect_ids
    elsif current_user
      aspects = current_user.aspects
      aspect = aspects.first
      aspect_ids = current_user.aspect_ids
    else
      return {}
    end

    { selected_aspects: aspects, aspect: aspect, aspect_ids: aspect_ids }
  end
end
