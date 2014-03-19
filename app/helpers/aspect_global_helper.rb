#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module AspectGlobalHelper
  def aspect_membership_dropdown(contact, person, hang, aspect=nil, force_bootstrap=false)
    aspect_membership_ids = {}

    selected_aspects = all_aspects.select{|aspect| contact.in_aspect?(aspect)}
    selected_aspects.each do |a|
      record = a.aspect_memberships.find { |am| am.contact_id == contact.id }
      aspect_membership_ids[a.id] = record.id
    end

    if bootstrap? || force_bootstrap
      render "aspect_memberships/aspect_membership_dropdown",
        :selected_aspects => selected_aspects,
        :aspect_membership_ids => aspect_membership_ids,
        :person => person,
        :hang => hang,
        :dropdown_class => "aspect_membership"
    else
      render "aspect_memberships/aspect_membership_dropdown_blueprint",
        :selected_aspects => selected_aspects,
        :aspect_membership_ids => aspect_membership_ids,
        :person => person,
        :hang => hang,
        :dropdown_class => "aspect_membership"
    end
  end

  def aspect_dropdown_list_item(aspect, am_id=nil)
    klass = am_id.present? ? "selected" : ""

    str = <<LISTITEM
<li data-aspect_id="#{aspect.id}" data-membership_id="#{am_id}" class="#{klass} aspect_selector">
  #{aspect.name}
</li>
LISTITEM
    str.html_safe
  end

  def dropdown_may_create_new_aspect
    @aspect == :profile || @aspect == :tag || @aspect == :search || @aspect == :notification || params[:action] == "getting_started"
  end

  def aspect_options_for_select(aspects)
    options = {}
    aspects.each do |aspect|
      options[aspect.to_s] = aspect.id
    end
    options
  end
end
