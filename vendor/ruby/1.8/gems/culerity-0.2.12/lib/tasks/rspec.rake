gem 'test-unit', '1.2.3' if RUBY_VERSION.to_f >= 1.9

# Don't load rspec if running "rake gems:*"
unless ARGV.any? {|a| a =~ /^gems/}

begin
  require 'spec/rake/spectask'
rescue MissingSourceFile
  module Spec
    module Rake
      class SpecTask
        def initialize(name)
          task name do
            # if rspec-rails is a configured gem, this will output helpful material and exit ...
            require File.expand_path(File.dirname(__FILE__) + "/../../config/environment")

            # ... otherwise, do this:
            raise <<-MSG

#{"*" * 80}
*  You are trying to run an rspec rake task defined in
*  #{__FILE__},
*  but rspec can not be found in vendor/gems, vendor/plugins or system gems.
#{"*" * 80}
MSG
          end
        end
      end
    end
  end
end

Rake.application.instance_variable_get('@tasks').delete('default')

spec_prereq = File.exist?(File.join(RAILS_ROOT, 'config', 'database.yml')) ? "db:test:prepare" : :noop
task :noop do
end

task :default => [:spec,:features]
task :stats => "spec:statsetup"

desc "Run all specs in spec directory (excluding plugin specs)"
Spec::Rake::SpecTask.new(:spec => spec_prereq) do |t|
  t.spec_opts = ['--options', "\"#{RAILS_ROOT}/spec/spec.opts\""]
  t.spec_files = FileList['spec/**/*/*_spec.rb']
end

desc "Run all specs in the spec directory with html output (excluding plugins specs)"
Spec::Rake::SpecTask.new(:spec_html => spec_prereq) do |t|
  t.spec_opts = ['--colour', '--format html', '--loadby mtime', '--reverse']
  t.spec_files = FileList['spec/**/*/*_spec.rb']
end

namespace :spec do
  desc "Run all specs in spec directory with RCov (excluding plugin specs)"
  Spec::Rake::SpecTask.new(:rcov) do |t|
    t.spec_opts = ['--options', "\"#{RAILS_ROOT}/spec/spec.opts\""]
    t.spec_files = FileList['spec/**/*/*_spec.rb']
    t.rcov = true
    t.rcov_opts = lambda do
      IO.readlines("#{RAILS_ROOT}/spec/rcov.opts").map {|l| l.chomp.split " "}.flatten
    end
  end
end

end