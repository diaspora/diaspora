# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

namespace :db do
  desc "Reset the current RAILS_ENV database and delete the upload-folder"
  task :purge do
    require File.join(File.dirname(__FILE__), "..", "..", "config", "environment")

    puts "Purging the database for #{Rails.env}..."

    Rake::Task["db:reset"].invoke

    puts "Deleting tmp folder..."
    `rm -rf #{File.dirname(__FILE__)}/../../public/uploads/*`
  end
end
