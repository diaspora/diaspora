#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module AspectGlobalHelper
  def aspect_membership_dropdown(contact, person, hang, aspect=nil)
    selected_aspects = all_aspects.select{|aspect| contact.in_aspect?(aspect)}

    render "shared/aspect_dropdown",
      :selected_aspects => selected_aspects,
      :person => person,
      :hang => hang,
      :dropdown_class => "aspect_membership"
  end

  def aspect_dropdown_list_item(aspect, checked)
    klass = checked ? "selected" : ""

    str = <<LISTITEM
<li data-aspect_id=#{aspect.id} class='#{klass} aspect_selector'>
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
