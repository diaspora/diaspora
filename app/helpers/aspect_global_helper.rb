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

 #aspect_badges takes an array of aspects, and a hash containing  a key called :link which hashes to either true or false, depending on whether the resulting badge should serve as a working link.
  #aspect_badges returns the the HTML code for an 'All Aspects' badge if the post is associated with all of a user's aspects, and returns HTML code for a collection of individual aspect badges if the post is associated with only some of a user's aspects
  def aspect_badges(aspects, opts={})
    str = ''
	if (!aspects.nil? && !@all_aspects.nil?)
		if aspects.count == @all_aspects.count
			str << "<span class='aspect_badge single'>"
			str << link_to(I18n.t('all_aspects'), aspects_path, :class => 'hard_aspect_link').html_safe
			str << "</span>"
		else
     		aspects.each do |aspect| 
       		str << aspect_badge(aspect, opts)
     		end
		end
	end
    str.html_safe
  end

# aspect_badge takes an aspect and returns the HTML code for an individual aspect badge
  def aspect_badge(aspect, opts={})
    str = "<span class='aspect_badge single'>"
    if !opts[:link]
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
end
