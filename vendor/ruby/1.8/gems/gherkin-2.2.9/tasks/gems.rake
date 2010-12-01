namespace :gems do
  task :win do
    unless File.directory?(File.expand_path('~/.rake-compiler'))
      STDERR.puts <<-EOM

You must install Windows rubies to ~/.rake-compiler with:

  rake-compiler cross-ruby VERSION=1.8.6-p287
  # (Later 1.9.1 patch levels don't compile on mingw) 
  rake-compiler cross-ruby VERSION=1.9.1-p243
EOM
      exit(1)
    end
    # rvm and mingw ruby versions have to match to avoid errors
    sh "rvm 1.8.6@cucumber rake cross compile RUBY_CC_VERSION=1.8.6"
    sh "rvm 1.9.1@cucumber rake cross compile RUBY_CC_VERSION=1.9.1"
    # This will copy the .so files to the proper place
    sh "rake cross compile RUBY_CC_VERSION=1.8.6:1.9.1"
  end

  desc 'Prepare JRuby binares'
  task :jruby => [:jar] do
    sh "rvm jruby@cucumber -S rspec spec"
  end

  desc 'Prepare IronRuby binaries'
  task :ironruby => [:jruby, 'ikvm:dll', 'ikvm:copy_ikvm_dlls']

  task :sanity do
    raise "The jruby gem looks too small" if File.stat("release/gherkin-#{Gherkin::VERSION}-java.gem").size < 1000000
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
