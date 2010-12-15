#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require File.join(Rails.root, 'lib/rake_helpers')
include RakeHelpers

namespace :migrations do

  desc 'make old registered services into the new class specific services'
  task :service_reclassify do
    require File.join(Rails.root,"config/environment")
    Service.all.each do |s|
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

  desc 'fix people with spaces in their diaspora handles'
  task :fix_space_in_diaspora_handles do
    RakeHelpers::fix_diaspora_handle_spaces(false)
  end

  task :contacts_as_requests do
    require File.join(Rails.root,"config/environment")
    puts "Migrating contacts..."
    MongoMapper.database.eval('
      db.contacts.find({pending : null}).forEach(function(contact){
        db.contacts.update({"_id" : contact["_id"]}, {"$set" : {"pending" : false}}); });')
    puts "Deleting stale requests..."
    Request.find_each(:sent => true){|request|
      request.delete
    }
    puts "Done!"
  end

  desc 'allow to upgrade old image urls to use rel path'
  task :switch_image_urls do
  end

  desc 'fix usernames with periods in them'
  task :fix_periods_in_username do
    RakeHelpers::fix_periods_in_usernames(false)
  end

  desc 'purge broken contacts'
  task :purge_broken_contacts do
  end
end
