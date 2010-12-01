namespace :release do
  desc 'Upload all packages and tag git'
  task :ALL => ['gems:sanity', :push_dll, :push_jar, :push_native_gems, :release]

  desc 'Push all gems to rubygems.org (gemcutter)'
  task :push_native_gems do
    Dir.chdir('release') do
      Dir['*.gem'].each do |gem_file|
        sh("gem push #{gem_file}")
      end
    end
  end

  desc 'Push dll to Github'
  task :push_dll => :ikvm do
    Dir.chdir('release') do
      # No known way to do scripted uploads. github/upload or aslakhellesoy's fork of github-gem no longer work
      puts "Manually upload gherkin-#{Gherkin::VERSION}.dll to http://github.com/aslakhellesoy/gherkin/downloads"
      puts "Then press enter"
      STDIN.gets
    end
  end

  desc 'Push jar to cukes.info Maven repo'
  task :push_jar do
    Dir.chdir('java') do
      sh("mvn -Dmaven.wagon.provider.http=httpclient deploy")
    end
  end
end