begin
  require 'metric_fu'
rescue LoadError
  namespace :metrics do
    task :all do
      abort 'metric_fu is not available. In order to run metrics:all, you must: gem install metric_fu'
    end
  end
end

begin
  require 'reek/adapters/rake_task'

  Reek::RakeTask.new do |t|
    t.fail_on_error = true
    t.verbose       = false
    t.source_files  = 'lib/**/*.rb'
  end
rescue LoadError
  task :reek do
    abort 'Reek is not available. In order to run reek, you must: gem install reek'
  end
end

begin
  require 'roodi'
  require 'roodi_task'

  RoodiTask.new do |t|
    t.verbose = false
  end
rescue LoadError
  task :roodi do
    abort 'Roodi is not available. In order to run roodi, you must: gem install roodi'
  end
end
