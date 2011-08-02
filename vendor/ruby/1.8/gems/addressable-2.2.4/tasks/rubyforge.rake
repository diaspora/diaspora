namespace :gem do
  desc 'Package and upload to RubyForge'
  task :release => ["gem:package", "gem:gemspec"] do |t|
    require 'rubyforge'

    v = ENV['VERSION'] or abort 'Must supply VERSION=x.y.z'
    abort "Versions don't match #{v} vs #{PROJ.version}" if v != PKG_VERSION
    pkg = "pkg/#{GEM_SPEC.full_name}"

    rf = RubyForge.new
    rf.configure
    puts 'Logging in...'
    rf.login

    c = rf.userconfig
    changelog = File.open("CHANGELOG") { |file| file.read }
    c['release_changes'] = changelog
    c['preformatted'] = true

    files = ["#{pkg}.tgz", "#{pkg}.zip", "#{pkg}.gem"]

    puts "Releasing #{PKG_NAME} v. #{PKG_VERSION}"
    rf.add_release RUBY_FORGE_PROJECT, PKG_NAME, PKG_VERSION, *files
  end
end

namespace :doc do
  desc "Publish RDoc to RubyForge"
  task :release => ["doc"] do
    require "rake/contrib/sshpublisher"
    require "yaml"

    config = YAML.load(
      File.read(File.expand_path('~/.rubyforge/user-config.yml'))
    )
    host = "#{config['username']}@rubyforge.org"
    remote_dir = RUBY_FORGE_PATH + "/api"
    local_dir = "doc"
    Rake::SshDirPublisher.new(host, remote_dir, local_dir).upload
  end
end

namespace :spec do
  desc "Publish specdoc to RubyForge"
  task :release => ["spec:specdoc"] do
    require "rake/contrib/sshpublisher"
    require "yaml"

    config = YAML.load(
      File.read(File.expand_path('~/.rubyforge/user-config.yml'))
    )
    host = "#{config['username']}@rubyforge.org"
    remote_dir = RUBY_FORGE_PATH + "/specdoc"
    local_dir = "specdoc"
    Rake::SshDirPublisher.new(host, remote_dir, local_dir).upload
  end

  namespace :rcov do
    desc "Publish coverage report to RubyForge"
    task :release => ["spec:rcov"] do
      require "rake/contrib/sshpublisher"
      require "yaml"

      config = YAML.load(
        File.read(File.expand_path('~/.rubyforge/user-config.yml'))
      )
      host = "#{config['username']}@rubyforge.org"
      remote_dir = RUBY_FORGE_PATH + "/coverage"
      local_dir = "coverage"
      Rake::SshDirPublisher.new(host, remote_dir, local_dir).upload
    end
  end
end

namespace :website do
  desc "Publish website to RubyForge"
  task :release => ["doc:release", "spec:release", "spec:rcov:release"] do
    require "rake/contrib/sshpublisher"
    require "yaml"

    config = YAML.load(
      File.read(File.expand_path('~/.rubyforge/user-config.yml'))
    )
    host = "#{config['username']}@rubyforge.org"
    remote_dir = RUBY_FORGE_PATH
    local_dir = "website"
    Rake::SshDirPublisher.new(host, remote_dir, local_dir).upload
  end
end
