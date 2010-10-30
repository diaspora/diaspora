task :default => [:cucumber, :spec, :'jasmine:ci']

task :'no-jasmine' => [:cucumber, :spec]