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
  # ==== Examples
  #
  #   # if user is not signed in
  #   current_color_theme # => "color_themes/original"
  #   # if user Alice has not selected a color theme
  #   current_color_theme # => "color_themes/original"
  #   # if user Alice has selected a "magenta" theme
  #   current_color_theme # => "color_themes/magenta"
  def current_color_theme
    if user_signed_in?
      color_theme = current_user.color_theme
    end
    color_theme ||= DEFAULT_COLOR_THEME
    current_color_theme = "color_themes/" + color_theme
  end

  # Returns an array of the color themes available, as
  # specified from AVAILABLE_COLOR_THEMES in
  # config/initializers/color_themes.rb.
  #
  # ==== Examples
  #
  #   # if config/color_themes.yml is:
  #   available:
  #     original: "Original dark"
  #     dark_green: "Dark green"
  #   # and AVAILABLE_COLOR_THEMES is accordingly initialized,
  #   # then:
  #   available_color_themes
  #   # => [["Original dark", "original"], ["Dark green", "dark_green"]]
  def available_color_themes
    opts = []
    AVAILABLE_COLOR_THEMES.each do |theme_code, theme_name|
      opts << [theme_name, theme_code]
    end
    opts
  end
end
