require 'fileutils'

PROJECTS = %w(oa-core oa-basic oa-enterprise oa-more oa-oauth oa-openid omniauth)

def root
  File.expand_path('../../', __FILE__)
end

require root + '/lib/omniauth/version'

def version
  ::OmniAuth::Version.constants.each do |const|
    ::OmniAuth::Version.send(:remove_const, const)
  end
  load root + '/lib/omniauth/version.rb'
  OmniAuth::Version::STRING
end

PROJECTS.each do |project|
  namespace project.to_sym do
    dir           = root + (project == 'omniauth' ? '' : "/#{project}")
    package_dir   = "#{dir}/pkg"
    coverage_dir  = "#{dir}/coverage"
    temp_dir      = "#{dir}/tmp"
    gem           = "#{project}-#{version}.gem"
    gemspec       = "#{project}.gemspec"

    task :clean do
      rm_rf package_dir
      rm_rf coverage_dir
      rm_rf temp_dir
    end

    task :build => :clean do
      cd dir
      sh "gem build #{gemspec}"
      mkdir_p package_dir unless Dir.exists?(package_dir)
      mv gem, "#{package_dir}/#{gem}"
    end

    task :install => :build do
      sh "gem install #{package_dir}/#{gem}"
    end

    task :push => :build do
      sh "gem push #{package_dir}/#{gem}"
    end

    task :version do
      puts "#{project}: #{version}"
    end

    namespace :version do

      destination = "#{dir}/lib/omniauth/version.rb"

      task :write do
        write_version(destination, ENV['MAJOR'], ENV['MINOR'], ENV['PATCH'], ENV['PRE'])
      end

      namespace :bump do

        task :major do
          bump_version(destination, 0)
        end

        task :minor do
          bump_version(destination, 1)
        end

        task :patch do
          bump_version(destination, 2)
        end

      end

    end

    task :spec do
      cd dir
      sh "#{$0} spec"
    end

  end
end

namespace :all do
  task :clean => PROJECTS.map{|project| "#{project}:clean"}
  task :build => PROJECTS.map{|project| "#{project}:build"}
  task :install => PROJECTS.map{|project| "#{project}:install"}
  task :push => PROJECTS.map{|project| "#{project}:push"}
  task "version" => PROJECTS.map{|project| "#{project}:version"}
  task "version:write" => PROJECTS.map{|project| "#{project}:version:write"} + [:version]
  task "version:bump:major" => PROJECTS.map{|project| "#{project}:version:bump:major"} + [:version]
  task "version:bump:minor" => PROJECTS.map{|project| "#{project}:version:bump:minor"} + [:version]
  task "version:bump:patch" => PROJECTS.map{|project| "#{project}:version:bump:patch"} + [:version]
  task :spec do
    errors = []
    PROJECTS.map do |project|
      next if project == "omniauth"
      Rake::Task["#{project}:spec"].invoke || errors << project
    end
    fail("Errors in #{errors.join(', ')}") unless errors.empty?
  end
end

def write_version(destination, major=nil, minor=nil, patch=nil, pre=nil)
  source = "#{root}/lib/omniauth/version.rb"
  v = version.split('.')
  v[0] = major if major
  v[1] = minor if minor
  v[2] = patch if patch
  v[3] = pre   if pre
  v[3] = v[3] ? v[3].to_s : "nil"

  ruby = File.read(source)
  ruby.gsub! /^(\s*)MAJOR = .*?$/, "\\1MAJOR = #{v[0]}"
  fail "Could not insert MAJOR in #{source}" unless $1
  ruby.gsub! /^(\s*)MINOR = .*?$/, "\\1MINOR = #{v[1]}"
  fail "Could not insert MINOR in #{source}" unless $1
  ruby.gsub! /^(\s*)PATCH = .*?$/, "\\1PATCH = #{v[2]}"
  fail "Could not insert PATCH in #{source}" unless $1
  ruby.gsub! /^(\s*)PRE   = .*?$/, "\\1PRE   = #{v[3]}"
  fail "Could not insert PRE in #{source}" unless $1
  File.open(destination, 'w') do |file|
    file.write ruby
  end
end

def bump_version(destination, position)
  v = version.split('.').map{|s| s.to_i}
  v[position] += 1
  write_version(destination, *v)
end
