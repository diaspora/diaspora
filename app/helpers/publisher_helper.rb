#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module PublisherHelper
  def remote?
    params[:controller] != "tags"
  end

  def service_button(service)
    provider_title = I18n.t(
      "services.index.share_to",
      provider: service.provider.titleize)
    content_tag :div,
                class:   "btn btn-link service_icon dim",
                title:   "#{provider_title} (#{service.nickname})",
                id:      "#{service.provider}",
                maxchar: "#{service.class::MAX_CHARACTERS}",
                data:    {toggle: "tooltip", placement: "bottom"} do
      if service.provider == "wordpress"
        content_tag(:span, "", class: "social-media-logos-wordpress-16x16")
      else
        content_tag(:i, "", class: "entypo-social-#{ service.provider } small")
      end
    end
  end
end
