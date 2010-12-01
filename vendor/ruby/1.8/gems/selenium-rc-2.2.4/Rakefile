require "spec"
require "spec/rake/spectask"

task :default => :spec

desc "Run all examples"
Spec::Rake::SpecTask.new("spec") do |t|
  t.spec_files = FileList["spec/**/*_spec.rb"]
end
