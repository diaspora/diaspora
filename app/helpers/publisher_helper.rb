# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module PublisherHelper
  def service_button(service)
    provider_title = I18n.t("services.index.share_to", provider: service.provider.titleize)
    content_tag :div,
                class:   "btn btn-link service_icon dim",
                title:   "#{provider_title} (#{service.nickname})",
                id:      service.provider,
                maxchar: service.class::MAX_CHARACTERS,
                data:    {toggle: "tooltip", placement: "bottom"} do
      if service.provider == "wordpress"
        content_tag(:span, "", class: "social-media-logos-wordpress-16x16")
      else
        content_tag(:i, "", class: "entypo-social-#{service.provider} small")
      end
    end
  end

  def public_selected?(selected_aspects)
    "public" == selected_aspects.try(:first) || publisher_boolean?(:public)
  end

  def all_aspects_selected?(selected_aspects)
    !all_aspects.empty? && all_aspects.size == selected_aspects.size && !public_selected?(selected_aspects)
  end

  def aspect_selected?(aspect, selected_aspects)
    selected_aspects.include?(aspect) && !all_aspects_selected?(selected_aspects) && !public_selected?(selected_aspects)
  end

  def publisher_open?
    publisher_boolean?(:open)
  end

  private

  def publisher_boolean?(option)
    @stream.try(:publisher).try(option) == true
  end
end
