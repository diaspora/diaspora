#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rake'
require 'resque/tasks'

# for rake 0.9.0
module Diaspora
  class Application
    include Rake::DSL
  end
end

namespace :spec do
  desc "Add files that DHH doesn't consider to be 'code' to stats"
  task :statsetup do
    require 'rails/code_statistics'

    class CodeStatistics
      alias calculate_statistics_orig calculate_statistics
      def calculate_statistics
        @pairs.inject({}) do |stats, pair|
          if 3 == pair.size
            stats[pair.first] = calculate_directory_statistics(pair[1], pair[2]); stats
          else
            stats[pair.first] = calculate_directory_statistics(pair.last); stats
          end
        end
      end
    end
    ::STATS_DIRECTORIES << ['Views',  'app/views', /\.(rhtml|erb|rb)$/]
    # note, I renamed all my rails-generated email fixtures to add .txt
    ::STATS_DIRECTORIES << ['Static HTML', 'public', /\.html$/]
    ::STATS_DIRECTORIES << ['Static CSS',  'public', /\.css$/]
    # ::STATS_DIRECTORIES << ['Static JS',  'public', /\.js$/]
    # prototype is ~5384 LOC all by itself - very hard to filter out

    ::CodeStatistics::TEST_TYPES << "Test Fixtures"
    ::CodeStatistics::TEST_TYPES << "Email Fixtures"
  end
end
task :stats => "spec:statsetup"

Diaspora::Application.load_tasks
