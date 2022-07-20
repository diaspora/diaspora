# frozen_string_literal: true

namespace :assets do
  # create new assets manifest for tasks which run after assets:precompile
  def assets_manifest
    return @assets_manifest if @assets_manifest

    config = Diaspora::Application.config
    path = File.join(config.paths["public"].first, config.assets.prefix)
    @assets_manifest = Sprockets::Manifest.new(Diaspora::Application.assets, path, config.assets.manifest)
  end

  desc "Generate error pages"
  task generate_error_pages: :environment do
    ApplicationController.view_context_class.assets_manifest = assets_manifest
    renderer = ErrorPageRenderer.new codes: [404, 422, 500]
    renderer.render
  end

  desc "Create non digest assets"
  task non_digest_assets: :environment do
    Diaspora::Application.config.assets.non_digest_assets.each do |asset|
      digested_path = assets_manifest.assets[asset]
      raise Sprockets::Rails::Helper::AssetNotFound, "Precompiled asset for '#{asset}' not found" unless digested_path

      full_digested_path     = File.join(assets_manifest.directory, digested_path)
      full_non_digested_path = File.join(assets_manifest.directory, asset)

      next unless FileUtils.uptodate?(full_digested_path, [full_non_digested_path])

      puts "Copying #{full_digested_path} to #{full_non_digested_path}"
      FileUtils.copy_file(full_digested_path, full_non_digested_path, true)
    end
  end

  # Augment precompile with error page generation
  Rake::Task[:precompile].enhance do
    Rake::Task["assets:generate_error_pages"].invoke
    Rake::Task["assets:non_digest_assets"].invoke
  end

  Rake::Task[:generate_error_pages].enhance ["yarn:install"]
end
