#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module PublisherHelper
  def remote?
    params[:controller] != "tags"
  end

  def all_aspects_selected?(selected_aspects)
    @all_aspects_selected ||= all_aspects.size == selected_aspects.size
  end

  def service_button(service)
    content_tag :div,
                :class => "btn btn-link service_icon dim",
                :title => "#{service.provider.titleize} (#{service.nickname})",
                :id => "#{service.provider}",
                :maxchar => "#{service.class::MAX_CHARACTERS}",
                :data  => {:toggle=>'tooltip', :placement=>'bottom'} do
      if service.provider == 'wordpress'
        content_tag(:span, '', :class => "social_media_logos-wordpress-16x16")
      else
        content_tag(:i, '', :class => "entypo small #{ service.provider }")
      end
    end
  end
end
