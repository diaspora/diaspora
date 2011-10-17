#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module AspectGlobalHelper
  def aspects_with_post(aspects, post)
    aspects.select do |aspect|
      AspectVisibility.exists?(:aspect_id => aspect.id, :shareable_id => post.id, :shareable_type => 'Post')
    end
  end

  def aspect_badges(aspects, opts={})
    str = ''
    aspects.each do |aspect|
      str << aspect_badge(aspect, opts)
    end
    str.html_safe
  end

  def aspect_badge(aspect, opts={})
    str = "<span class='aspect_badge single'>"
    link = opts.delete(:link)
    if !link
      str << link_to(aspect.name, "#", 'data-guid' => aspect.id, :class => 'hard_aspect_link').html_safe
    else
      str << link_for_aspect(aspect).html_safe
    end
    str << "</span>"
  end

  def aspect_links(aspects, opts={})
    str = ""
    aspects.each do |aspect|
      str << '<li>'
      str << link_for_aspect(aspect, :params => opts, 'data-guid' => aspect.id, :class => 'hard_aspect_link').html_safe
      str << '</li>'
    end
    str.html_safe
  end

  def link_for_aspect(aspect, opts={})
    opts[:params] ||= {}
    params ||= {}
    opts[:params] = opts[:params].merge("a_ids[]" => aspect.id, :created_at => params[:created_at])
    opts[:class] ||= ""
    opts[:class] << " hard_aspect_link"
    opts['data-guid'] = aspect.id

    link_to aspect.name, aspects_path( opts[:params] ), opts
  end

  def aspect_or_all_path(aspect)
    if @aspect.is_a? Aspect
      aspect_path @aspect
    else
      aspects_path
    end
  end

  def aspect_membership_dropdown(contact, person, hang, aspect=nil)
    selected_aspects = all_aspects.select{|aspect| contact.in_aspect?(aspect) }

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
end
