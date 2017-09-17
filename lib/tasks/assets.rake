# frozen_string_literal: true

namespace :assets do
  desc "Generate error pages"
  task :generate_error_pages => :environment do
    renderer = ErrorPageRenderer.new codes: [404, 422, 500]
    renderer.render
  end

  desc "Create non digest assets"
  task non_digest_assets: :environment do
    logger = ::Logging::Logger["assets:non_digest_assets"]

    non_digest_assets = Diaspora::Application.config.assets.non_digest_assets

    Rails.application.assets_manifest.assets.each do |logical_path, digested_path|
      logical_pathname = Pathname.new(logical_path)
      next unless non_digest_assets.any? {|testpath| logical_pathname.fnmatch?(testpath, File::FNM_PATHNAME) }

      full_digested_path     = Rails.root.join("public", "assets", digested_path)
      full_non_digested_path = Rails.root.join("public", "assets", logical_path)

      next unless FileUtils.uptodate?(full_digested_path, [full_non_digested_path])

      logger.info "Copying #{full_digested_path} to #{full_non_digested_path}"

      FileUtils.copy_file(full_digested_path, full_non_digested_path, true)
    end
  end

  # Augment precompile with error page generation
  task :precompile do
    Rake::Task["assets:generate_error_pages"].invoke
    Rake::Task["assets:non_digest_assets"].invoke
  end
end
