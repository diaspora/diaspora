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

  # Augment precompile with error page generation
  task :precompile do
    Rake::Task['assets:generate_error_pages'].invoke
    Rake::Task['assets:uglify_bookmarklet'].invoke
  end
end
