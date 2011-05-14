#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module AspectGlobalHelper
  def aspects_with_post(aspects, post)
    aspects.select do |aspect|
      AspectVisibility.exists?(:aspect_id => aspect.id, :post_id => post.id)
    end
  end

  def aspects_without_post(aspects, post)
    aspects.reject do |aspect|
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

  def aspect_li(aspect, opts={})
    param_string = ""
    if opts.size > 0
      param_string << '?'
      opts.each_pair do |k, v|
        param_string << "#{k}=#{v}"
      end
    end
"<li>
  <a href='/aspects/#{aspect.id}#{param_string}'>
    #{aspect.name}
  </a>
</li>".html_safe
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

  def current_aspect?(aspect)
    !@aspect.nil? && !@aspect.instance_of?(Symbol) && @aspect.id == aspect.id
  end

  def aspect_or_all_path(aspect)
    if @aspect.is_a? Aspect
      aspect_path @aspect
    else
      aspects_path
    end
  end

  def aspect_dropdown_list_item(aspect, contact, person)
    checked = (contact.persisted? && contact.aspect_memberships.detect{ |am| am.aspect_id == aspect.id}) ? "checked=\"checked\"" : ""
    str = "<li data-aspect_id=#{aspect.id}>"
    str << "<input #{checked} id=\"in_aspect\" name=\"in_aspect\" type=\"checkbox\" value=\"in_aspect\" />"
    str << aspect.name
    str << "<div class=\"hidden\">"
    str << aspect_membership_button(aspect, contact, person)
    str.html_safe
  end
end
