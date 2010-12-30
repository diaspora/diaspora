#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require File.join(Rails.root, 'lib/rake_helpers')
include RakeHelpers

namespace :migrations do
  desc 'export data for mysql import'
  task :export_for_mysql do
    require 'lib/mongo_to_mysql'
    migrator = MongoToMysql.new
    db_name = "diaspora-development"
    models = [
      :aspects,
      :comments,
      :contacts,
      :invitations,
      :notifications,
      :people,
      :posts,
      :requests,
      :users,
    ]
    `mkdir -p #{Rails.root}/tmp/export-for-mysql`
    models.each do |model|
      filename = "#{Rails.root}/tmp/export-for-mysql/#{model}.json"
      `mongoexport -d #{db_name} -c #{model} | #{migrator.id_sed} | #{migrator.date_sed} > #{filename}`
      puts "#{model} exported to #{filename}"
      #`mongoexport -d #{db_name} -c #{model} -jsonArray | sed 's/\"[^"]*\"/"IAMID"/g' > #{filename}`
    end
  end
end
