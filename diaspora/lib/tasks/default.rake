task :default => [:spec, :cucumber, :'jasmine:ci']

task :'no-jasmine' => [:cucumber, :spec]