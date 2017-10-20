# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

# These helper methods can be called in your template to set variables to be used in the layout
# This module should be included in all views globally,
# to do so you may need to add this line to your ApplicationController
#   helper :layout
module LayoutHelper
  include ApplicationHelper

  def title(page_title, show_title = true)
    content_for(:title) { page_title.to_s }
    @show_title = show_title
  end

  def page_title(text=nil)
    return text unless text.blank?
    pod_name
  end

  def load_javascript_locales(section = 'javascripts')
    nonced_javascript_tag do
      <<-JS.html_safe
        Diaspora.I18n.load(#{get_javascript_strings_for(I18n.locale, section).to_json},
                           "#{I18n.locale}",
                           #{get_javascript_strings_for(DEFAULT_LANGUAGE, section).to_json});
        Diaspora.Page = "#{params[:controller].camelcase}#{params[:action].camelcase}";
      JS
    end
  end

  def current_user_atom_tag
    return unless @person.present?
    content_tag(:link, "", rel: "alternate", href: @person.atom_url, type: "application/atom+xml",
                title: t("layouts.application.public_feed", name: @person.name))
  end

  def translation_missing_warnings
    return if Rails.env == "production"

    content_tag(:style) do
      <<-CSS
        .translation_missing { color: purple; background-color: red; }
      CSS
    end
  end

  def include_color_theme(view="desktop")
    stylesheet_link_tag "#{current_color_theme}/#{view}", media: "all"
  end

  def flash_messages
    flash.map do |name, msg|
      klass = flash_class name
      content_tag(:div, msg, class: "flash-body expose") do
        content_tag(:div, msg, class: "flash-message message alert alert-#{klass}", role: "alert")
      end
    end.join(' ').html_safe
  end
end
