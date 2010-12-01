require 'rake/rdoctask'

load 'spec/tasks.rake'

desc 'Default: run specs.'
task :default => :spec

desc 'Generate RDoc documentation for the will_paginate plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_files.include('README.rdoc', 'LICENSE', 'CHANGELOG.rdoc').
    include('lib/**/*.rb').
    exclude('lib/will_paginate/finders/active_record/named_scope*').
    exclude('lib/will_paginate/finders/sequel.rb').
    exclude('lib/will_paginate/view_helpers/merb.rb').
    exclude('lib/will_paginate/deprecation.rb').
    exclude('lib/will_paginate/core_ext.rb').
    exclude('lib/will_paginate/version.rb')
  
  rdoc.main = "README.rdoc" # page to start on
  rdoc.title = "will_paginate documentation"
  
  rdoc.rdoc_dir = 'doc' # rdoc output folder
  rdoc.options << '--inline-source' << '--charset=UTF-8'
  rdoc.options << '--webcvs=http://github.com/mislav/will_paginate/tree/master/'
end

task :website do
  Dir.chdir('website') do
    %x(haml index.haml index.html)
    %x(sass pagination.sass pagination.css)
  end
end
