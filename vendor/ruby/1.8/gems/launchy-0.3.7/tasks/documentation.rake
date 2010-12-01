require 'tasks/config'

#-----------------------------------------------------------------------
# Documentation
#-----------------------------------------------------------------------

if rdoc_config = Configuration.for_if_exist?('rdoc') then

  namespace :doc do

    require 'rdoc'
    require 'rake/rdoctask'

    # generating documentation locally
    Rake::RDocTask.new do |rdoc|
      rdoc.rdoc_dir   = rdoc_config.output_dir
      rdoc.options    = rdoc_config.options
      rdoc.rdoc_files = rdoc_config.files.sort
      rdoc.title      = rdoc_config.title
      rdoc.main       = rdoc_config.main_page
    end 

    if rubyforge_config = Configuration.for_if_exist?('rubyforge') then
      desc "Deploy the RDoc documentation to #{rubyforge_config.rdoc_location}"
      task :deploy => :rerdoc do
        sh "rsync -zav --delete #{rdoc_config.output_dir}/ #{rubyforge_config.rdoc_location}"
      end 
    end 

  end 
end

