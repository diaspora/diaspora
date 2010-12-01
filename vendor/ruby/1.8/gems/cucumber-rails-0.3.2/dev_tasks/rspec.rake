begin
  require 'spec/rake/spectask'

  desc "Run RSpec"
  Spec::Rake::SpecTask.new do |t|
    t.spec_opts = %w{--color --diff --format profile}
    t.spec_files = FileList['spec/**/*_spec.rb']
    t.rcov = ENV['RCOV']
    t.rcov_opts = %w{--exclude osx\/objc,gems\/,spec\/}
  end
rescue LoadError
  task :spec
end
