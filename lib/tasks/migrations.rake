namespace :migrations do
  desc 'make old registered services into the new class specific services'
  task :service_reclassify do
    Service.all.each do |s|
      provider = s.provider
      s._type = "Services::#{provider.camelize}"
      s.save
    end
  end

  desc 'allow to upgrade old image urls to use rel path'
  task :swtich_image_urls do

  
  
  end

  desc 'move all posts and photos to new schema'
  task :migrate_status_message_to_posts do
  end
end
