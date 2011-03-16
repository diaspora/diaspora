#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.


module Job
  class ProcessPhoto < Base 
    @queue = :photos
    def self.perform_delegate(photo_id)
      begin
        Photo.find(photo_id).image.post_process
      rescue Exception => e
        puts e.inspect

      ensure
        puts "photo has been processed"
      end
    end
  end
end
