# frozen_string_literal: true

# Generate the path to the .yml file with the available color themes.
color_themes_file = Rails.root.join("config/color_themes.yml")
# Check in case config/color_themes.yml does not exist.
if color_themes_file.exist?
  # Load the file specified by the generated path.
  color_themes = YAML.load_file(color_themes_file)
  # If the file contains one or more color themes, include them in AVAILABLE_COLOR_THEMES,
  # else include the original theme.
  AVAILABLE_COLOR_THEMES =
    if color_themes["available"].length > 0
      color_themes["available"].freeze
    else
      ["original"].freeze
    end
else
  AVAILABLE_COLOR_THEMES = ["original"].freeze
end
