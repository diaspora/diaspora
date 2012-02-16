#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

# These helper methods can be called in your template to set variables to be used in the layout
# This module should be included in all views globally,
# to do so you may need to add this line to your ApplicationController
#   helper :layout
module LayoutHelper
  def title(page_title, show_title = true)
    content_for(:title) { page_title.to_s }
    @show_title = show_title
  end

  def page_title(text=nil)
    return text unless text.blank?
    current_user ? current_user.name : t("application.helper.diaspora_alpha")
  end

  def set_asset_host
    content_tag(:script) do
      <<-JS.html_safe
        app.baseImageUrl("#{ENV['ASSET_HOST']}")
      JS
    end
  end

  def load_javascript_locales
    content_tag(:script) do
      <<-JS.html_safe
        Diaspora.I18n.loadLocale(#{get_javascript_strings_for(I18n.locale).to_json}, "#{I18n.locale}");
        Diaspora.Page = "#{params[:controller].camelcase}#{params[:action].camelcase}";
      JS
    end
  end

  def set_current_user_in_javascript
    return unless current_user
    current_user_presenter = UserPresenter.new(current_user)
    
    content_tag(:script) do
      <<-JS.html_safe
        app.user(#{current_user_presenter.to_json});
      JS
    end
  end

  def current_user_atom_tag
    return unless @person.present?
    content_tag(:link, '', :rel => 'alternate', :href => "#{@person.public_url}.atom", :type => "application/atom+xml", :title => t('.public_feed', :name => @person.name))
  end

  def translation_missing_warnings
    return if Rails.env == "production"

    content_tag(:style) do
      <<-CSS
        .translation_missing { color: purple; background-color: red; }
      CSS
    end
  end

  def include_base_css_framework
    if @aspect == :getting_started || @page == :logged_out
      include_stylesheets :bootstrap
    else
      include_stylesheets :blueprint, :media => 'screen'
    end
  end

  def old_browser_js_support
    content_tag(:script) do
      <<-JS.html_safe
        if(Array.isArray === undefined) {
          Array.isArray = function (arg) {
            return Object.prototype.toString.call(arg) == '[object Array]';
          };
        }
        if ((window.history) && (window.history.pushState === undefined)) {
          window.history.pushState = function() { };
        }
      JS
    end
  end

  def flash_messages
    return if @page == :logged_out

    flash.map do |name, msg|
      content_tag(:div, :id => "flash_#{name}") do
        content_tag(:div, msg, :class => 'message')
      end
    end.join(' ').html_safe
  end
end
