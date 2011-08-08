namespace :backup do
  desc "Backup Mysql"
  require File.join(Rails.root, 'config', 'initializers', '_load_app_config.rb')
  require 'cloudfiles'

  task :mysql do
    NUMBER_OF_DAYS = 3
    puts("event=backup status=start type=mysql")
    db = YAML::load(File.open(File.join(File.dirname(__FILE__), '..','..', 'config', 'database.yml')))
    user = db['production']['username']
    password = db['production']['password']
    database = db['production']['database']
    unless AppConfig[:cloudfiles_username] && AppConfig[:cloudfiles_api_key] && !user.blank?
      puts "Cloudfiles username needed" unless AppConfig[:cloudfiles_username]
      puts "Cloudfiles api_key needed" unless AppConfig[:cloudfiles_api_key]
      puts "DB auth data needed" if user.blank?
      Process.exit
    end

    puts "Logging into Cloud Files"

    cf = CloudFiles::Connection.new(:username => AppConfig[:cloudfiles_username], :api_key => AppConfig[:cloudfiles_api_key])
    mysql_container = cf.container("MySQL Backup")

    puts "Dumping Mysql at #{Time.now.to_s}"
    `mkdir -p /tmp/backup/mysql`
    `nice mysqldump --single-transaction --user=#{user} --password=#{password} #{database} >> /tmp/backup/mysql/backup.txt `

    puts "Gzipping dump at #{Time.now.to_s}"
    tar_name = "mysql_#{Time.now.to_i}.tar"
    `nice tar cfPz /tmp/backup/#{tar_name} /tmp/backup/mysql`

    file = mysql_container.create_object(tar_name)

    puts "Uploading archive at #{Time.now.to_s}"
    if file.write File.open("/tmp/backup/" + tar_name)
      puts("event=backup status=success type=mysql")
      `rm /tmp/backup/#{tar_name}`
      `rm -rf /tmp/backup/mysql/`

      files = mysql_container.objects
      files.sort!.pop(NUMBER_OF_DAYS * 24)
      files.each do |file|
        mysql_container.delete_object(file)
      end
    else
      puts("event=backup status=failure type=mysql")
    end
  end

  task :photos do
    puts("event=backup status=start type=photos")

    if AppConfig[:cloudfiles_username] && AppConfig[:cloudfiles_api_key]
      puts "Logging into Cloud Files"

      cf = CloudFiles::Connection.new(:username => AppConfig[:cloudfiles_username], :api_key => AppConfig[:cloudfiles_api_key])
      photo_container = cf.container("Photo Backup")

      tar_name = "photos_#{Time.now.to_i}.tar"
      `tar cfPz /dev/stdout /usr/local/app/diaspora/public/uploads/images/ | split -d -b 4831838208 - /tmp/backup/#{tar_name}`

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
