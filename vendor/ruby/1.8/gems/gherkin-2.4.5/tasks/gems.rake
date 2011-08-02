namespace :gems do
  task :win do
    unless File.directory?(File.expand_path('~/.rake-compiler'))
      STDERR.puts "[ERROR] You must install MinGW rubies to build gherkin gems for Windows. See README.rdoc"
      exit(1)
    end
    # rvm and mingw ruby versions have to match to avoid errors
    sh "rvm 1.8.6-p399@cucumber rake cross compile RUBY_CC_VERSION=1.8.6"
    sh "rvm 1.9.1-p243@cucumber rake cross compile RUBY_CC_VERSION=1.9.1"
    # This will copy the .so files to the proper place
    sh "rake -t cross compile RUBY_CC_VERSION=1.8.6:1.9.1"
  end

  desc 'Prepare JRuby binares'
  task :jruby => [:jar] do
    sh "rvm jruby@cucumber exec rspec spec"
  end

  desc 'Prepare IronRuby binaries'
  task :ironruby => [:jruby, 'ikvm:dll', 'ikvm:copy_ikvm_dlls']

  task :sanity do
    raise "The jruby gem looks too small" if File.stat("release/gherkin-#{GHERKIN_VERSION}-java.gem").size < 1000000
  end

  desc "Prepare binaries for all gems"
  task :prepare => [
    :clean,
    :spec,
    :win,
    :jruby,
    :ironruby
  ]

end
