
if HAVE_SPEC_RAKE_SPECTASK and not PROJ.spec.files.to_a.empty?
require 'spec/rake/verify_rcov'

namespace :spec do

  desc 'Run all specs with basic output'
  Spec::Rake::SpecTask.new(:run) do |t|
    t.ruby_opts = PROJ.ruby_opts
    t.spec_opts = PROJ.spec.opts
    t.spec_files = PROJ.spec.files
    t.libs += PROJ.libs
  end

  desc 'Run all specs with text output'
  Spec::Rake::SpecTask.new(:specdoc) do |t|
    t.ruby_opts = PROJ.ruby_opts
    t.spec_opts = PROJ.spec.opts + ['--format', 'specdoc']
    t.spec_files = PROJ.spec.files
    t.libs += PROJ.libs
  end

  if HAVE_RCOV
    desc 'Run all specs with RCov'
    Spec::Rake::SpecTask.new(:rcov) do |t|
      t.ruby_opts = PROJ.ruby_opts
      t.spec_opts = PROJ.spec.opts
      t.spec_files = PROJ.spec.files
      t.libs += PROJ.libs
      t.rcov = true
      t.rcov_dir = PROJ.rcov.dir
      t.rcov_opts = PROJ.rcov.opts + ['--exclude', 'spec']
    end

    RCov::VerifyTask.new(:verify) do |t| 
      t.threshold = PROJ.rcov.threshold
      t.index_html = File.join(PROJ.rcov.dir, 'index.html')
      t.require_exact_threshold = PROJ.rcov.threshold_exact
    end

    task :verify => :rcov
    remove_desc_for_task %w(spec:clobber_rcov)
  end

end  # namespace :spec

desc 'Alias to spec:run'
task :spec => 'spec:run'

task :clobber => 'spec:clobber_rcov' if HAVE_RCOV

end  # if HAVE_SPEC_RAKE_SPECTASK

# EOF
