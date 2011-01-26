module LocalizeHelper
  def localize language
    yml_path = File.join(Rails.root, "config/locales/diaspora/", "#{language}.yml")
    yaml = YAML::load IO.read(yml_path)

    yaml[language]["javascripts"]
  end
end