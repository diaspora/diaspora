# frozen_string_literal: true

module UsersHelper
  def owner_image_tag(size=nil)
    person_image_tag(current_user.person, size)
  end

  def owner_image_link
    person_image_link(current_user.person, :size => :thumb_small)
  end

  # Returns the path of the current color theme so that it
  # can be loaded in app/views/layouts/application.html.haml
  # and app/views/layouts/application.mobile.haml. If the user
  # is not signed in or has not specified a color theme, the
  # default (original) color theme is loaded.
  #
  # @example if user is not signed in
  #   current_color_theme #=> "color_themes/original"
  # @example if user Alice has not selected a color theme
  #   current_color_theme #=> "color_themes/original"
  # @example if user Alice has selected a "magenta" theme
  #   current_color_theme #=> "color_themes/magenta"
  def current_color_theme
    if user_signed_in?
      color_theme = current_user.color_theme
    end
    color_theme ||= AppConfig.settings.default_color_theme
    "color_themes/#{color_theme}"
  end

  # Returns an array of the color themes available, as
  # specified from AVAILABLE_COLOR_THEMES in
  # config/initializers/color_themes.rb.
  #
  # @example if AVAILABLE_COLOR_THEMES = ["original", "dark_green"]
  #   available_color_themes
  #   #=> [["Original gray", "original"], ["Dark green", "dark_green"]]
  def available_color_themes
    opts = []
    AVAILABLE_COLOR_THEMES.map do |theme_code|
      opts << [I18n.t("color_themes.#{theme_code}"), theme_code]
    end
    opts
  end
end
