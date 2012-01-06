#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.


module Jobs
  class ProcessPhoto < Base
    @queue = :photos
    def self.perform(id, after_process = nil)
      photo = Photo.find(id)
      unprocessed_image = photo.unprocessed_image

      return false if photo.processed? || unprocessed_image.path.try(:include?, ".gif")

      photo.processed_image.store!(unprocessed_image)
      photo.update_remote_path

      result = photo.save!

      after_process.call( photo ) unless( after_process.nil? )
      
      result
    end
    
    def self.update_profile( a_photo )
      profile_params = { :image_url => a_photo.url(:thumb_large),
                         :image_url_medium => a_photo.url(:thumb_medium),
                         :image_url_small => a_photo.url(:thumb_small)}
                         
      a_photo.author.owner.update_profile(profile_params)
    end
    
  end
end
