# -*- ruby encoding: utf-8 -*-

require "rubygems"
require 'hoe'

Hoe.plugin :doofus
Hoe.plugin :git
Hoe.plugin :gemspec
Hoe.plugin :rubyforge

Hoe.spec 'net-ldap' do |spec|
  spec.rubyforge_name = spec.name

  spec.developer("Francis Cianfrocca", "blackhedd@rubyforge.org")
  spec.developer("Emiel van de Laar", "gemiel@gmail.com")
  spec.developer("Rory O'Connell", "rory.ocon@gmail.com")
  spec.developer("Kaspar Schiess", "kaspar.schiess@absurd.li")
  spec.developer("Austin Ziegler", "austin@rubyforge.org")

  spec.remote_rdoc_dir = ''
  spec.rsync_args << ' --exclude=statsvn/'

  spec.url = %W(http://net-ldap.rubyforge.org/ https://github.com/ruby-ldap/ruby-net-ldap)

  spec.history_file = 'History.rdoc'
  spec.readme_file = 'README.rdoc'

  spec.extra_rdoc_files = FileList["*.rdoc"].to_a

  spec.extra_dev_deps << [ "hoe-git", "~> 1" ]
  spec.extra_dev_deps << [ "hoe-gemspec", "~> 1" ]
  spec.extra_dev_deps << [ "metaid", "~> 1" ]
  spec.extra_dev_deps << [ "flexmock", "~> 0.9.0" ]
  spec.extra_dev_deps << [ "rspec", "~> 2.0" ]

  spec.clean_globs << "coverage"

  spec.spec_extras[:required_ruby_version] = ">= 1.8.7"
  spec.multiruby_skip << "1.8.6"
  spec.multiruby_skip << "1_8_6"

  spec.need_tar = true
end

# I'm not quite ready to get rid of this, but I think "rake git:manifest" is
# sufficient.
namespace :old do
  desc "Build the manifest file from the current set of files."
  task :build_manifest do |t|
    require 'find'

    paths = []
    Find.find(".") do |path|
      next if File.directory?(path)
      next if path =~ /\.svn/
        next if path =~ /\.git/
        next if path =~ /\.hoerc/
        next if path =~ /\.swp$/
        next if path =~ %r{coverage/}
      next if path =~ /~$/
        paths << path.sub(%r{^\./}, '')
    end

    File.open("Manifest.txt", "w") do |f|
      f.puts paths.sort.join("\n")
    end

    puts paths.sort.join("\n")
  end
end

desc "Run a full set of integration and unit tests" 
task :cruise => [:test, :spec]

# vim: syntax=ruby
