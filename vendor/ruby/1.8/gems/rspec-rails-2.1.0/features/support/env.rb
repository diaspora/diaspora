require 'aruba'
require 'webrat'

module Aruba::Api
  alias_method :orig_run, :run

  def run(cmd, fail_on_error=false)
    if cmd =~ /^rspec/
      orig_run("bundle exec #{cmd}", fail_on_error)
    else
      orig_run(cmd, fail_on_error)
    end
  end
end

Before do
  unset_bundler_env_vars
end

unless File.directory?('./tmp/example_app')
  system "rake generate:app generate:stuff"
end

def aruba_path(file_or_dir)
  File.expand_path("../../../#{file_or_dir.sub('example_app','aruba')}", __FILE__)
end

def example_app_path(file_or_dir)
  File.expand_path("../../../#{file_or_dir}", __FILE__)
end

def write_symlink(file_or_dir)
  source = example_app_path(file_or_dir)
  target = aruba_path(file_or_dir)
  system "ln -s #{source} #{target}"
end

def copy(file_or_dir)
  source = example_app_path(file_or_dir)
  target = aruba_path(file_or_dir)
  system "cp -r #{source} #{target}"
end


Before do
  steps %Q{
    Given a directory named "spec"
  }

  Dir['tmp/example_app/*'].each do |file_or_dir|
    if !(file_or_dir =~ /spec$/)
      write_symlink(file_or_dir)
    end
  end

  ["spec/spec_helper.rb"].each do |file_or_dir|
    write_symlink("tmp/example_app/#{file_or_dir}")
  end

end

Around do |scenario, block|
  Bundler.with_clean_env &block
end

