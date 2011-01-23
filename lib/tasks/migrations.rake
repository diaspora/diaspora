# Copyright (c) 2010, Diaspora Inc.  This file is
# licensed under the Affero General Public License version 3 or later.  See
# the COPYRIGHT file.

require File.join(Rails.root, 'lib', 'data_conversion', 'base')
require File.join(Rails.root, 'lib', 'data_conversion', 'export_from_mongo')
require File.join(Rails.root, 'lib', 'data_conversion', 'import_to_mysql')

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
  task :import_to_mysql do
    require File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment')
    migrator = DataConversion::ImportToMysql.new
    migrator.full_path = "/tmp/data_conversion/csv"
    migrator.log("**** Starting import to MySQL database #{ActiveRecord::Base.connection.current_database} ****")
    migrator.import_raw
    migrator.process_raw_tables
    migrator.log("**** Import finished! ****")
    migrator.log("total elapsed time")
  end

  desc 'execute mongo to mysql migration.  Requires mongoexport to be accessible.'
  task :migrate_to_mysql => [:export_for_mysql, :import_to_mysql]

  desc 'absolutify all existing image references'
  task :absolutify_image_references do
    require File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment')

    Photo.all.each do |photo|
      unless photo.remote_photo_path
        # extract root
        #
        pod = URI::parse(photo.person.url)
        pod_url = "#{pod.scheme}://#{pod.host}" 

        if photo.image.url
          remote_path = "#{photo.image.url}"
        else
          puts pod_url
          remote_path = "#{pod_url}#{photo.remote_photo_path}/#{photo.remote_photo_name}"
        end

        # get path/filename
        name_start = remote_path.rindex '/'
        photo.remote_photo_path = "#{remote_path.slice(0, name_start)}/"
        photo.remote_photo_name = remote_path.slice(name_start + 1, remote_path.length)

        photo.save!
      end
    end
  end

  task :upload_photos_to_s3 do
    require File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment')
    puts AppConfig[:s3_key]
    
    connection = Aws::S3.new( AppConfig[:s3_key], AppConfig[:s3_secret])
    bucket = connection.bucket('joindiaspora')
    dir_name = File.dirname(__FILE__) + "/../../public/uploads/images/"
    
    count = Dir.foreach(dir_name).count
    current = 0

    Dir.foreach(dir_name){|file_name| puts file_name;
      if file_name != '.' && file_name != '..';
        begin
          key = Aws::S3::Key.create(bucket, 'uploads/images/' + file_name);
          key.put(File.open(dir_name+ '/' + file_name).read, 'public-read');
          key.public_link();
          puts "Uploaded #{current} of #{count}"
          current += 1
        rescue Exception => e
          puts "error #{e} on #{current} (#{file_name}), retrying"
          retry
        end
      end 
    }

  end
end
