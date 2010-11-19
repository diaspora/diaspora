namespace :backup do
  desc "Backup Mongo"
  task :mongo do
    require File.join(Rails.root, 'config', 'initializers', '_load_app_config.rb')
    require 'cloudfiles'

    if APP_CONFIG[:cloudfiles_username] && APP_CONFIG[:cloudfiles_api_key]
      puts "Loginning into Cloud Files"
      cf = CloudFiles::Connection.new(:username => APP_CONFIG[:cloudfiles_username], :api_key => APP_CONFIG[:cloudfiles_api_key])
      mongo_container = cf.container("Mongo Backup")

      puts "Dumping Mongo"
      `mongodump -o /tmp/backup/mongo`
      puts "Taring the archive"
      tar_name = "mongo_#{Time.now.to_i}.tar"
      `tar cfP /tmp/backup/#{tar_name} /tmp/backup/mongo`
      
      file = mongo_container.create_object(tar_name)
      puts "uploading"
      success = file.write File.open("/tmp/backup/" + tar_name)
      puts "Successfully uploaded?: #{success}"
      if success
        `rm /tmp/backup/#{tar_name}`
        `rm -rf /tmp/backup/mongo/`
      end 
    else
      puts "Cloudfiles username and api key needed"
    end
  end
end
