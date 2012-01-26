namespace :assets do
	task :compile_s3 do
    puts "compiling sass..."
    system 'sass --update public/stylesheets/sass:public/stylesheets'

    puts "packaging assets....."
    Jammit.package!

    Rake::Task['assets:upload_to_s3'].invoke
	end

  task :upload_to_s3 => [:environment] do
   s3_configuration = {
     :bucket_name => AppConfig[:s3_bucket],
     :access_key_id =>  AppConfig[:s3_key],
     :secret_access_key => AppConfig[:s3_secret]
   } 
   Jammit.upload_to_s3!(s3_configuration)
   asset_host = "https://#{s3_configuration[:bucket_name]}.s3.amazonaws.com"
   puts "NOTE: ENV['ASSET_HOST'] is now: #{asset_host}, but you may know your cdn url better than I"
   puts "Please set this in your ENV hash in a production enviroment"
  end
end