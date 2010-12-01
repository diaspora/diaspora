
require 'rake/rdoctask'

namespace :doc do

  desc 'Generate RDoc documentation'
  Rake::RDocTask.new do |rd|
    rdoc = PROJ.rdoc
    rd.main = rdoc.main
    rd.rdoc_dir = rdoc.dir

    incl = Regexp.new(rdoc.include.join('|'))
    excl = Regexp.new(rdoc.exclude.join('|'))
    files = PROJ.gem.files.find_all do |fn|
              case fn
              when excl; false
              when incl; true
              else false end
            end
    rd.rdoc_files.push(*files)

    title = "#{PROJ.name}-#{PROJ.version} Documentation"

    rf_name = PROJ.rubyforge.name
    title = "#{rf_name}'s " + title if rf_name.valid? and rf_name != title

    rd.options << "-t #{title}"
    rd.options.concat(rdoc.opts)
  end

  desc 'Generate ri locally for testing'
  task :ri => :clobber_ri do
    sh "#{RDOC} --ri -o ri ."
  end

  task :clobber_ri do
    rm_r 'ri' rescue nil
  end

end  # namespace :doc

desc 'Alias to doc:rdoc'
task :doc => 'doc:rdoc'

desc 'Remove all build products'
task :clobber => %w(doc:clobber_rdoc doc:clobber_ri)

remove_desc_for_task %w(doc:clobber_rdoc)

# EOF
