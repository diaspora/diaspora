#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rake/dsl_definition'
require 'rake'
require 'resque/tasks'

#include Rake::DSL if defined?(Rake::DSL)
# for rake 0.9.0
#module Diaspora
#  class Application
#    include Rake::DSL
#  end
#end

#module ::RakeFileUtils
#  extend Rake::FileUtilsExt
#end

Diaspora::Application.load_tasks
