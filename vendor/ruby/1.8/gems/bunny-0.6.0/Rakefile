desc "Run AMQP 0-8 rspec tests"
task :spec08 do
	require 'spec/rake/spectask'
	puts "===== Running 0-8 tests ====="
	Spec::Rake::SpecTask.new("spec08") do |t|
		t.spec_files = FileList["spec/spec_08/*_spec.rb"]
		t.spec_opts = ['--color']
	end
end

desc "Run AMQP 0-9 rspec tests"
task :spec09 do
	require 'spec/rake/spectask'
	puts "===== Running 0-9 tests ====="
	Spec::Rake::SpecTask.new("spec09") do |t|
		t.spec_files = FileList["spec/spec_09/*_spec.rb"]
		t.spec_opts = ['--color']
	end
end

task :default => [ :spec08 ]

desc "Run all rspec tests"
task :all => [:spec08, :spec09]