namespace :assets do
  desc "Generate error pages"
  task :generate_error_pages => :environment do
    renderer = ErrorPageRenderer.new codes: [404, 422, 500]
    renderer.render
  end

  desc "Uglify bookmarklet snippet"
  task :uglify_bookmarklet => :environment do
    BookmarkletRenderer.compile
  end

  desc "Create non digest assets"
  task non_digest_assets: :environment do
    logger = ::Logging::Logger["assets:non_digest_assets"]

    non_digest_assets = Diaspora::Application.config.assets.non_digest_assets
    manifest_path = Dir.glob(File.join(Rails.root, "public/assets/manifest-*.json")).first

    JSON.load(File.new(manifest_path))["assets"].each do |logical_path, digested_path|
      logical_pathname = Pathname.new(logical_path)
      next unless non_digest_assets.any? {|testpath| logical_pathname.fnmatch?(testpath, File::FNM_PATHNAME) }

      full_digested_path     = File.join(Rails.root, "public/assets", digested_path)
      full_non_digested_path = File.join(Rails.root, "public/assets", logical_path)

      next unless FileUtils.uptodate?(full_digested_path, [full_non_digested_path])

      logger.info "Copying #{full_digested_path} to #{full_non_digested_path}"

      FileUtils.copy_file(full_digested_path, full_non_digested_path, true)
    end
  end

  # Augment precompile with error page generation
  task :precompile do
    Rake::Task["assets:generate_error_pages"].invoke
    Rake::Task["assets:uglify_bookmarklet"].invoke
    Rake::Task["assets:non_digest_assets"].invoke
  end
end
