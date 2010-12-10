namespace :migrations do
  desc 'make old registered services into the new class specific services'

  task :service_reclassify do
    require File.join(Rails.root,"config/environment")
    #include ActiveSupport::Inflector
    Service.all.each do |s|
      puts s.inspect
      
      provider = s.provider
      if provider
        s._type = "Services::#{provider.camelize}"
        s.save
      else
        puts "no provider found for service #{s.id}"
      end
    end
    puts "all done"
  end

  desc 'allow to upgrade old image urls to use rel path'
  task :swtich_image_urls do

  end

  desc 'move all posts and photos to new schema'
  task :migrate_status_message_to_posts do
  end
end
