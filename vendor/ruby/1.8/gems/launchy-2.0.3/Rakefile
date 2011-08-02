#--
# Copyright (c) 2007 Jeremy Hinegardner
# All rights reserved.  See LICENSE and/or COPYING for details.
#++

begin
  require 'bones'
rescue LoadError
  abort '### Please install the "bones" gem ###'
end

task :default => 'test:run'
task 'gem:release' => 'test:run'

$:.unshift( "lib" )
require 'launchy/version'

Bones {
  name      "launchy"
  authors   "Jeremy Hinegardner"
  email     "jeremy@copiousfreetime.org"
  url       'http://www.copiousfreetime.org/projects/launchy'
  version   Launchy::VERSION

  ruby_opts     %w[ -W0 -rubygems ]
  readme_file   'README'
  ignore_file   '.gitignore'
  history_file  'HISTORY'

  rdoc.include << "README" << "HISTORY" << "LICENSE"

  summary 'Launchy is helper class for launching cross-platform applications in a fire and forget manner.'
  description <<_
Launchy is helper class for launching cross-platform applications in a
fire and forget manner.

There are application concepts (browser, email client, etc) that are
common across all platforms, and they may be launched differently on
each platform.  Launchy is here to make a common approach to launching
external application from within ruby programs.
_

  if RUBY_PLATFORM == "java" then
    depend_on "spoon"   , "~> 0.0.1"
    gem.extras = { :platform => Gem::Platform.new( "java" ) }
  end

  depend_on "rake"      , "~> 0.9.2", :development => true
  depend_on "minitest"  , "~> 2.3.1", :development => true
  depend_on 'bones'     , "~> 3.7.0", :development => true
  depend_on 'bones-rcov', "~> 1.0.1", :development => true
  depend_on 'rcov'      , "~> 0.9.9", :development => true
  depend_on "spoon"     , "~> 0.0.1", :development => true

  test.files = FileList["spec/**/*_spec.rb"]
  test.opts << "-w -Ilib:spec"

  rcov.opts << "--exclude gems"
}
