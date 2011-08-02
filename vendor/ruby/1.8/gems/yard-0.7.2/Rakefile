require File.dirname(__FILE__) + '/lib/yard'
require File.dirname(__FILE__) + '/lib/yard/rubygems/specification'
require 'rbconfig'

YARD::VERSION.replace(ENV['YARD_VERSION']) if ENV['YARD_VERSION']
WINDOWS = (Config::CONFIG['host_os'] =~ /mingw|win32|cygwin/ ? true : false) rescue false
SUDO = WINDOWS ? '' : 'sudo'

task :default => :specs

desc "Builds the gem"
task :gem do
  Gem::Builder.new(eval(File.read('yard.gemspec'))).build
end

desc "Installs the gem"
task :install => :gem do 
  sh "#{SUDO} gem install yard-#{YARD::VERSION}.gem --no-rdoc --no-ri"
end

desc 'Run spec suite'
task :suite do
  ['ruby186', 'ruby18', 'ruby19', 'ruby192', 'jruby'].each do |ruby|
    2.times do |legacy|
      next if legacy == 1 && ruby =~ /^jruby|186/
      puts "Running specs with #{ruby}#{legacy == 1 ? ' (in legacy mode)' : ''}"
      cmd = "#{ruby} -S rake specs SUITE=1 #{legacy == 1 ? 'LEGACY=1' : ''}"
      puts cmd
      system(cmd)
    end
  end
end

begin
  hide = '_spec\.rb$,spec_helper\.rb$,ruby_lex\.rb$,autoload\.rb$'
  if YARD::Parser::SourceParser.parser_type == :ruby
    hide += ',legacy\/.+_handler'
  else
    hide += ',ruby_parser\.rb$,ast_node\.rb$,handlers\/ruby\/[^\/]+\.rb$'
  end

  require 'rspec'
  require 'rspec/core/rake_task'

  desc "Run all specs"
  RSpec::Core::RakeTask.new("specs") do |t|
    $DEBUG = true if ENV['DEBUG']
    t.rspec_opts = ENV['SUITE'] ? ['--format', 'progress'] : ["--colour", "--format", "documentation"]
    t.rspec_opts += ["--require", File.join(File.dirname(__FILE__), 'spec', 'spec_helper')]
    t.rspec_opts += ['-I', YARD::ROOT]
    t.pattern = "spec/**/*_spec.rb"
    t.verbose = $DEBUG ? true : false
  
    if ENV['RCOV']
      t.rcov = true 
      t.rcov_opts = ['-x', hide]
    end
  end
  task :spec => :specs
rescue LoadError
  begin # Try for rspec 1.x
    require 'spec'
    require 'spec/rake/spectask'
    
    Spec::Rake::SpecTask.new("specs") do |t|
      $DEBUG = true if ENV['DEBUG']
      t.spec_opts = ["--format", "specdoc", "--colour"]
      t.spec_opts += ["--require", File.join(File.dirname(__FILE__), 'spec', 'spec_helper')]
      t.pattern = "spec/**/*_spec.rb"

      if ENV['RCOV']
        t.rcov = true 
        t.rcov_opts = ['-x', hide]
      end
    end
    task :spec => :specs
  rescue LoadError
    warn "warn: RSpec tests not available. `gem install rspec` to enable them."
  end
end

YARD::Rake::YardocTask.new do |t|
  t.options += ['--title', "YARD #{YARD::VERSION} Documentation"]
end
