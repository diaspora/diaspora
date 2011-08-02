require 'spec/rake/spectask'

spec_opts = 'spec/spec.opts'

desc 'Run framework-agnostic specs'
Spec::Rake::SpecTask.new(:spec) do |t|
  t.libs << 'spec'
  t.spec_opts = ['--options', spec_opts]
  t.spec_files = FileList.new('spec/**/*_spec.rb') do |files|
    files.exclude(/\b(active_record|active_resource|action_view|data_mapper|sequel)_/)
  end
end

namespace :spec do
  desc 'Run specs for core, ActiveRecord and ActionView'
  Spec::Rake::SpecTask.new(:rails) do |t|
    t.libs << 'spec'
    t.spec_opts = ['--options', spec_opts]
    t.spec_files = FileList.new('spec/**/*_spec.rb') do |files|
      files.exclude(/\b(data_mapper|sequel)_/)
    end
  end
  
  desc 'Run specs for DataMapper'
  Spec::Rake::SpecTask.new(:datamapper) do |t|
    t.libs << 'spec'
    t.spec_opts = ['--options', spec_opts]
    t.spec_files = FileList.new('spec/finders_spec.rb', 'spec/finders/data_mapper_spec.rb')
  end
  
  desc 'Run specs for Sequel'
  Spec::Rake::SpecTask.new(:sequel) do |t|
    t.libs << 'spec'
    t.spec_opts = ['--options', spec_opts]
    t.spec_files = FileList.new('spec/finders_spec.rb', 'spec/finders/sequel_spec.rb')
  end
  
  desc 'Analyze spec coverage with RCov'
  Spec::Rake::SpecTask.new(:rcov) do |t|
    t.libs << 'spec'
    t.spec_opts = ['--options', spec_opts]
    t.rcov = true
    t.rcov_opts = lambda do
      IO.readlines('spec/rcov.opts').map { |l| l.chomp.split(" ") }.flatten
    end
  end
  
  desc 'Print Specdoc for all specs'
  Spec::Rake::SpecTask.new(:doc) do |t|
    t.libs << 'spec'
    t.spec_opts = ['--format', 'specdoc', '--dry-run']
  end
  
  desc 'Generate HTML report'
  Spec::Rake::SpecTask.new(:html) do |t|
    t.libs << 'spec'
    t.spec_opts = ['--format', 'html:doc/spec_results.html', '--diff']
    t.fail_on_error = false
  end
end
