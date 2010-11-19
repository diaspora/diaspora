namespace :backup do
  desc "Backup Mongo"
  task :mongo do
    require 'cloudfiles'

    if APP_CONFIG[:cloudfiles_username] && APP_CONFIG[:cloudfiles_api_key]
      cf = CloudFiles::Connection.new(:username => APP_CONFIG[:cloudfiles_username], :api_key => APP_CONFIG[:cloudfiles_api_key])
      mongo_container = cf.container("Mongo Backup")

      `mongodump -o /tmp/backup/mongo`
      tar_name = "mongo_#{Time.now.to_i}.tar"
      `tar cfP /tmp/backup/#{tar_name} /tmp/backup/mongo`
      file = mongo_container.create_object(tar_name)
      success = file.write File.open("/tmp/backup/" + tar_name)
      if success
        `rm /tmp/backup/#{tar_name}`
        `rm -rf /tmp/backup/mongo/`
      end 
    else
      puts "Cloudfiles username and api key needed"
    end
  end
end
