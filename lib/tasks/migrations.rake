# Copyright (c) 2010, Diaspora Inc.  This file is
# licensed under the Affero General Public License version 3 or later.  See
# the COPYRIGHT file.

Dir.glob(File.join(Rails.root, 'lib', 'data_conversion', '*.rb')).each { |f| require f }

namespace :migrations do
  desc 'export data for mysql import'
  task :export_for_mysql do
    migrator = DataConversion::ExportFromMongo.new
    migrator.log("**** Starting export for MySQL ****")
    migrator.clear_dir
    migrator.write_json_export
    migrator.convert_json_files
    migrator.log("**** Export finished! ****")
    migrator.log("total elapsed time")
  end
end
