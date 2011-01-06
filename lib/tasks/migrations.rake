# Copyright (c) 2010, Diaspora Inc.  This file is
# licensed under the Affero General Public License version 3 or later.  See
# the COPYRIGHT file.

Dir.glob(File.join(Rails.root, 'lib', 'data_conversion', '*.rb')).each { |f| require f }

namespace :migrations do
  desc 'export data for mysql import'
  task :export_for_mysql do
    migrator = DataConversion::ExportFromMongo.new
    migrator.full_path = "/tmp/data_conversion"
    migrator.log("**** Starting export for MySQL ****")
    migrator.clear_dir
    migrator.write_json_export
    migrator.convert_json_files
    migrator.log("**** Export finished! ****")
    migrator.log("total elapsed time")
  end

  desc 'import data to mysql'
  task :import_to_mysql => :environment do
    migrator = DataConversion::ImportToMysql.new
    migrator.full_path = "/tmp/data_conversion/csv"
    migrator.log("**** Starting import to MySQL database #{ActiveRecord::Base.connection.current_database} ****")
    migrator.import_raw
    migrator.process_raw_tables
    migrator.log("**** Import finished! ****")
    migrator.log("total elapsed time")
  end
end
