#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

namespace :migrations do
  desc 'export data for mysql import'
  task :export_for_mysql do
    require File.join(Rails.root, 'lib', 'mongo_to_mysql')
    migrator = MongoToMysql.new
    migrator.log("**** Starting export for MySQL ****")
    migrator.clear_dir
    migrator.write_json_export
    migrator.convert_json_files
    migrator.log("**** Export finished! ****")
    migrator.log("total elapsed time")
  end
end
