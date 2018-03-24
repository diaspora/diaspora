# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# bootstrap-markdown plugin relies on rails-assets-bootstrap gem but we use
# bootstrap-sass this line makes sure we exclude every asset comming
# from rails-assets-bootstrap to prevent conflicts with bootstrap-sass

# See https://github.com/tenex/rails-assets/issues/314
Rails.application.config.after_initialize do
  # add the gem names you wish to reject to the below array
  excluded_gem_names = ["rails-assets-bootstrap"]

  excluded_gem_full_names = Gem::Specification.select {|g| excluded_gem_names.include? g.name }.flat_map(&:full_name)
  Rails.application.config.assets.paths.reject! do |path|
    excluded_gem_full_names.any? {|gem_name| path.include? gem_name }
  end
end

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = "1.0"

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.
# Rails.application.config.assets.paths << Rails.root.join("node_modules")

Rails.application.config.public_file_server.enabled = AppConfig.environment.assets.serve?
