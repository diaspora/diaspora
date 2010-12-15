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
    old_contacts =  Contact.all(:pending => nil)
    old_contacts.each{|contact| contact.pending = false; contact.save}
    puts "all done"
  end

  desc 'allow to upgrade old image urls to use rel path'
  task :swtich_image_urls do
  end

  desc 'fix usernames with periods in them'
  task :fix_periods_in_username do
    RakeHelpers::fix_periods_in_usernames(false)
  end

  desc 'purge broken contacts'
  task :purge_broken_contacts do
  end
end
