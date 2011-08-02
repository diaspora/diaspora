require "rake/gempackagetask"

namespace :gem do
  GEM_SPEC = Gem::Specification.new do |s|
    unless s.respond_to?(:add_development_dependency)
      puts "The gem spec requires a newer version of RubyGems."
      exit(1)
    end

    s.name = PKG_NAME
    s.version = PKG_VERSION
    s.summary = PKG_SUMMARY
    s.description = PKG_DESCRIPTION

    s.files = PKG_FILES.to_a

    s.has_rdoc = true
    s.extra_rdoc_files = %w( README )
    s.rdoc_options.concat ["--main",  "README"]

    s.add_development_dependency("rake", ">= 0.8.3")
    s.add_development_dependency("rspec", ">= 1.1.11")
    s.add_development_dependency("launchy", ">= 0.3.2")

    s.require_path = "lib"

    s.author = "Bob Aman"
    s.email = "bob@sporkmonger.com"
    s.homepage = "http://#{PKG_NAME}.rubyforge.org/"
    s.rubyforge_project = RUBY_FORGE_PROJECT
  end

  Rake::GemPackageTask.new(GEM_SPEC) do |p|
    p.gem_spec = GEM_SPEC
    p.need_tar = true
    p.need_zip = true
  end

  desc "Show information about the gem"
  task :debug do
    puts GEM_SPEC.to_ruby
  end

  desc "Install the gem"
  task :install => ["clobber", "gem:package"] do
    sh "#{SUDO} gem install --local pkg/#{GEM_SPEC.full_name}"
  end

  desc "Uninstall the gem"
  task :uninstall do
    installed_list = Gem.source_index.find_name(PKG_NAME)
    if installed_list &&
        (installed_list.collect { |s| s.version.to_s}.include?(PKG_VERSION))
      sh(
        "#{SUDO} gem uninstall --version '#{PKG_VERSION}' " +
        "--ignore-dependencies --executables #{PKG_NAME}"
      )
    end
  end

  desc "Reinstall the gem"
  task :reinstall => [:uninstall, :install]
end

desc "Alias to gem:package"
task "gem" => "gem:package"

task "clobber" => ["gem:clobber_package"]
