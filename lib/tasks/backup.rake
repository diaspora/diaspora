namespace :backup do
  desc "Backup Mongo"
  require File.join(Rails.root, 'config', 'initializers', '_load_app_config.rb')
  require 'cloudfiles'

  task :mongo do
    puts("event=backup status=start type=mongo")

    if AppConfig[:cloudfiles_username] && AppConfig[:cloudfiles_api_key]
      puts "Logging into Cloud Files"

      cf = CloudFiles::Connection.new(:username => AppConfig[:cloudfiles_username], :api_key => AppConfig[:cloudfiles_api_key])
      mongo_container = cf.container("Mongo Backup")

      puts "Dumping Mongo"
      `mongodump -o /tmp/backup/mongo`

      tar_name = "mongo_#{Time.now.to_i}.tar"
      `tar cfP /tmp/backup/#{tar_name} /tmp/backup/mongo`

      file = mongo_container.create_object(tar_name)

      if file.write File.open("/tmp/backup/" + tar_name)
        puts("event=backup status=success type=mongo")
        `rm /tmp/backup/#{tar_name}`
        `rm -rf /tmp/backup/mongo/`
      else
        puts("event=backup status=failure type=mongo")
      end
    else
      puts "Cloudfiles username and api key needed"
    end
  end

  task :photos do
    puts("event=backup status=start type=photos")

    if AppConfig[:cloudfiles_username] && AppConfig[:cloudfiles_api_key]
      puts "Logging into Cloud Files"

      cf = CloudFiles::Connection.new(:username => AppConfig[:cloudfiles_username], :api_key => AppConfig[:cloudfiles_api_key])
      photo_container = cf.container("Photo Backup")

      tar_name = "photos_#{Time.now.to_i}.tar"
      `tar cfP /dev/stdout /usr/local/app/diaspora/public/uploads/images/ | split -d -b 4831838208 - /tmp/backup/#{tar_name}`

      (0..99).each do |n|
        padded_str = n.to_s.rjust(2,'0')
        file = photo_container.create_object(tar_name + padded_str)
        file_path = "/tmp/backup/" + tar_name + padded_str

        if File.exists?(file_path)
          if file.write File.open(file_path)
            puts("event=backup status=success type=photos")
          else
            puts("event=backup status=failure type=photos")
          end
          `rm #{file_path}`
        end
      end

    else
      puts "Cloudfiles username and api key needed"
    end
  end
end
