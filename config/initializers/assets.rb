# Be sure to restart your server when you modify this file.

# bootstrap-markdown plugin relies on rails-assets-bootstrap gem but we use
# bootstrap-sass this line makes sure we exclude every asset comming
# from rails-assets-bootstrap to prevent conflicts with bootstrap-sass
Rails.configuration.assets.paths.reject! do |path|
  path.include?("rails-assets-bootstrap") && !path.include?("rails-assets-bootstrap-markdown")
end

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = "1.0"

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.
# Rails.application.config.assets.paths << Rails.root.join("node_modules")

Rails.application.config.public_file_server.enabled = AppConfig.environment.assets.serve?
