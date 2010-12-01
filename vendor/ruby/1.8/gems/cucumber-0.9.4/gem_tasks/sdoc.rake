begin
  require 'rake/rdoctask'
  require 'sdoc' # and use your RDoc task the same way you used it before

  Rake::RDocTask.new(:sdoc) do |rdoc|
    rdoc.rdoc_dir = 'doc/sdoc'
    rdoc.title = "Cucumber"
    rdoc.options += %w{--fmt shtml -N --webcvs=http://github.com/aslakhellesoy/cucumber/blob/v0.3.96/%s --title "Cucumber API" --threads 4 --main README --exclude cucumber/parser lib}
    rdoc.template = 'direct' # lighter template used on railsapi.com
  end
rescue LoadError => ignore
end
