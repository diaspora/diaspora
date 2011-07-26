#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module AspectGlobalHelper
  def aspects_with_post(aspects, post)
    aspects.select do |aspect|
      AspectVisibility.exists?(:aspect_id => aspect.id, :post_id => post.id)
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

  def aspect_listing_link_opts aspect
    if controller.instance_of?(ContactsController)
      {:href => contacts_path(:a_id => aspect.id)}
    else
      {:href => aspects_path("a_ids[]" => aspect.id), :class => "aspect_selector name hard_aspect_link", 'data-guid' => aspect.id}
    end
  end

  def aspect_or_all_path(aspect)
    if @aspect.is_a? Aspect
      aspect_path @aspect
    else
      aspects_path
    end
  end

  def aspectmembership_dropdown(contact, person, hang, aspect=nil)
    @selected_aspects = []
    if contact.persisted?
      @selected_aspects = all_aspects.find_all{|aspect| contact.aspect_memberships.detect{ |am| am.aspect_id == aspect.id}}
    end
    @selected_aspects = [@selected_aspects] if @selected_aspects.kind_of? Aspect

    render "shared/aspect_dropdown",
      :contact => @contact,
      :selected_aspects => @selected_aspects,
      :person => person,
      :hang => hang,
      :dropdown_class => "aspect_membership",
      :button_class => ("in_aspects" if @selected_aspects.size > 0),
      :may_create_new_aspect => ( @aspect == :profile || @aspect == :tag || @aspect == :search || @aspect == :notification)
  end

  def aspect_dropdown_list_item(aspect, checked)
    klass = checked ? "selected" : ""

    str = <<LISTITEM
<li data-aspect_id=#{aspect.id} class='#{klass}'>
  <img src='/images/icons/check_yes_ok.png' width=18 height=18 class='check'/>
  <img src='/images/icons/check_yes_ok_white.png' width=18 height=18 class='checkWhite'/>
  #{aspect.name}
</li>
LISTITEM
    str.html_safe
  end
end
