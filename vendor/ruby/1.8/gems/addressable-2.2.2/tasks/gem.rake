require "rake/gempackagetask"

namespace :gem do
  GEM_SPEC = Gem::Specification.new do |s|
    s.name = PKG_NAME
    s.version = PKG_VERSION
    s.summary = PKG_SUMMARY
    s.description = PKG_DESCRIPTION

    s.files = PKG_FILES.to_a

    s.has_rdoc = true
    s.extra_rdoc_files = %w( README )
    s.rdoc_options.concat ["--main",  "README"]

    if !s.respond_to?(:add_development_dependency)
      puts "Cannot build Gem with this version of RubyGems."
      exit(1)
    end

    s.add_development_dependency("rake", ">= 0.7.3")
    s.add_development_dependency("rspec", ">= 1.0.8")
    s.add_development_dependency("launchy", ">= 0.3.2")
    s.add_development_dependency("diff-lcs", ">= 1.1.2")

    s.require_path = "lib"

    s.author = "Bob Aman"
    s.email = "bob@sporkmonger.com"
    s.homepage = RUBY_FORGE_URL
    s.rubyforge_project = RUBY_FORGE_PROJECT
  end

  Rake::GemPackageTask.new(GEM_SPEC) do |p|
    p.gem_spec = GEM_SPEC
    p.need_tar = true
    p.need_zip = true
  end

  desc "Generates .gemspec file"
  task :gemspec do
    spec_string = GEM_SPEC.to_ruby

    begin
      Thread.new { eval("$SAFE = 3\n#{spec_string}", binding) }.join
    rescue
      abort "unsafe gemspec: #{$!}"
    else
      File.open("#{GEM_SPEC.name}.gemspec", 'w') do |file|
        file.write spec_string
      end
    end
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
