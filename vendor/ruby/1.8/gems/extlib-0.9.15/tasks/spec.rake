require 'spec/rake/spectask'
require 'spec/rake/verify_rcov'

spec_defaults = lambda do |spec|
  spec.pattern    = 'spec/**/*_spec.rb'
  spec.libs      << 'lib' << 'spec'
  spec.spec_opts << '--options' << 'spec/spec.opts'
end

Spec::Rake::SpecTask.new(:spec, &spec_defaults)

Spec::Rake::SpecTask.new(:rcov) do |rcov|
  spec_defaults.call(rcov)
  rcov.rcov      = true
  rcov.rcov_opts = File.read('spec/rcov.opts').split(/\s+/)
end

RCov::VerifyTask.new(:verify_rcov => :rcov) do |rcov|
  rcov.threshold = 100
end

task :spec => :check_dependencies
task :rcov => :check_dependencies

task :default => :spec
