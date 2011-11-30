namespace :backup do
  desc "Backup Tasks"
  require File.join(Rails.root, 'config', 'initializers', '_load_app_config.rb')
  require 'cloudfiles'
  require 'fileutils'

  tmp_backup_dir = "./tmp/backup"
  tmp_sql_file = "backup.sql"
  tmp_db_dir = "db"

  task :all => [:database, :photos]

  task :mysql => [:database]

  task :postgresql => [:database]

  task :database do
    puts("event=backup status=start type=database")
    tmp_pass_file = ".pgpass.conf.tmp"
    db = YAML::load(File.open(File.join(File.dirname(__FILE__), '..','..', 'config', 'database.yml')))
    host = db['production']['host']
    port = db['production']['port'].to_s
    user = db['production']['username']
    password = db['production']['password']
    database = db['production']['database']

    unless AppConfig[:cloudfiles_username] && AppConfig[:cloudfiles_api_key] && AppConfig[:cloudfiles_db_container] && 
        AppConfig[:backup_retention_days] && !user.blank?

      puts "Cloudfiles username needed" unless AppConfig[:cloudfiles_username]
      puts "Cloudfiles api_key needed" unless AppConfig[:cloudfiles_api_key]
      puts "Cloudfiles database container needed" unless AppConfig[:cloudfiles_db_container]
      puts "Retention period needed" unless AppConfig[:backup_retention_days]
      puts "Database auth data needed" if user.blank?
      Process.exit
    end

    puts "Logging into Cloud Files"

    cf = CloudFiles::Connection.new(:username => AppConfig[:cloudfiles_username], :api_key => AppConfig[:cloudfiles_api_key])

    FileUtils.mkdir_p(tmp_backup_dir + "/" + tmp_db_dir)
    container = cf.container(AppConfig[:cloudfiles_db_container])

    if db['production']['adapter'] == 'postgresql'
      file = File.new(tmp_backup_dir + "/" + tmp_pass_file, 'w')
      file.chmod( 0600 )
      file.write(host + ":" + 
                 port + ":" + 
                 database + ":" + 
                 user + ":" + 
                 password + "\n")
      file.close

      puts "Dumping PostgreSQL at #{Time.now.to_s}"
      `PGPASSFILE=#{tmp_backup_dir}/#{tmp_pass_file} nice pg_dump -h #{host} -p #{port} -U #{user} #{database} > #{tmp_backup_dir}/#{tmp_db_dir}/#{tmp_sql_file} `
      File.delete(tmp_backup_dir + "/" + tmp_pass_file)

      puts "Gzipping dump at #{Time.now.to_s}"
      tar_name = "postgresql_#{Time.now.to_i}.tar"
      `nice tar cfPz #{tmp_backup_dir}/#{tar_name} #{tmp_backup_dir}/#{tmp_db_dir}`
    elsif db['production']['adapter'] == 'mysql2'
      puts "Dumping Mysql at #{Time.now.to_s}"
      `nice mysqldump --single-transaction --quick --user=#{user} --password=#{password} #{database} > #{tmp_backup_dir}/#{tmp_db_dir}/#{tmp_sql_file} `

      puts "Gzipping dump at #{Time.now.to_s}"
      tar_name = "mysql_#{Time.now.to_i}.tar"
      `nice tar cfPz #{tmp_backup_dir}/#{tar_name} #{tmp_backup_dir}/#{tmp_db_dir}`
    end

    file = container.create_object(tar_name)

    puts "Uploading archive at #{Time.now.to_s}"
    if file.write File.open(tmp_backup_dir + "/" + tar_name)
      puts("event=backup status=success type=database")

      File.delete(tmp_backup_dir + "/" + tar_name)
      File.delete(tmp_backup_dir + "/" + tmp_db_dir + "/" + tmp_sql_file)
      Dir.delete(tmp_backup_dir + "/" + tmp_db_dir)
      Dir.delete(tmp_backup_dir)

      puts("Deleting Cloud Files objects that are older than specified retention period")
      files = container.objects
      files.each do |file|
        object = container.object(file)
        if object.last_modified < (Time.now - (AppConfig[:backup_retention_days] * 24 * 60 * 60))
          puts("Deleting expired Cloud Files object: " + file)
          container.delete_object(file)
        end
      end
    else
      puts("event=backup status=failure type=database")
    end
  end

  task :photos do
    puts("event=backup status=start type=photos")

    if AppConfig[:cloudfiles_username] && AppConfig[:cloudfiles_api_key] && AppConfig[:cloudfiles_images_container]
      puts "Logging into Cloud Files"

      cf = CloudFiles::Connection.new(:username => AppConfig[:cloudfiles_username], :api_key => AppConfig[:cloudfiles_api_key])
      container = cf.container(AppConfig[:cloudfiles_images_container])

      images_dir = File.join(File.dirname(__FILE__), '..', '..', 'public/uploads/images/')
      FileUtils.mkdir_p(tmp_backup_dir)
      tar_name = "photos_#{Time.now.to_i}.tar"
      `tar cfPz /dev/stdout #{images_dir} | split -d -b 4831838208 - #{tmp_backup_dir}/#{tar_name}`

      (0..99).each do |n|
        padded_str = n.to_s.rjust(2,'0')
        file = container.create_object(tar_name + padded_str)
        file_path = tmp_backup_dir + "/" + tar_name + padded_str

        if File.exists?(file_path)
          if file.write File.open(file_path)
            puts("event=backup status=success type=photos")
          else
            puts("event=backup status=failure type=photos")
          end
          File.delete(file_path)
        end
      end

      Dir.delete(tmp_backup_dir)

      puts("Deleting Cloud Files objects that are older than specified retention period")
      files = container.objects
      files.each do |file|
        object = container.object(file)
        if object.last_modified < (Time.now - (AppConfig[:backup_retention_days] * 24 * 60 * 60))
          puts("Deleting expired Cloud Files object: " + file)
          container.delete_object(file)
        end
      end
    else
      puts "Cloudfiles username and api key needed"
    end
  end
end
