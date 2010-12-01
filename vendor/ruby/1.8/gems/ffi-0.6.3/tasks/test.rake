
if test(?e, PROJ.test.file) or not PROJ.test.files.to_a.empty?
require 'rake/testtask'

namespace :test do

  Rake::TestTask.new(:run) do |t|
    t.libs = PROJ.libs
    t.test_files = if test(?f, PROJ.test.file) then [PROJ.test.file]
                   else PROJ.test.files end
    t.ruby_opts += PROJ.ruby_opts
    t.ruby_opts += PROJ.test.opts
  end

  if HAVE_RCOV
    desc 'Run rcov on the unit tests'
    task :rcov => :clobber_rcov do
      opts = PROJ.rcov.opts.dup << '-o' << PROJ.rcov.dir
      opts = opts.join(' ')
      files = if test(?f, PROJ.test.file) then [PROJ.test.file]
              else PROJ.test.files end
      files = files.join(' ')
      sh "#{RCOV} #{files} #{opts}"
    end

    task :clobber_rcov do
      rm_r 'coverage' rescue nil
    end
  end

end  # namespace :test

desc 'Alias to test:run'
task :test => 'test:run'

task :clobber => 'test:clobber_rcov' if HAVE_RCOV

end

# EOF
