#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.


module Jobs
  class FetchProfilePhoto < Base
    @queue = :photos
    def self.perform(user_id, service_id)
      user = User.find(user_id)
      service = Service.find(service_id)

      @photo = Photo.new
      @photo.author = user.person
      @photo.diaspora_handle = user.person.diaspora_handle
      @photo.random_string = ActiveSupport::SecureRandom.hex(10)
      @photo.remote_unprocessed_image_url = service.profile_photo_url
      @photo.save!
      
      profile_params = {:image_url => @photo.url(:thumb_large),
                       :image_url_medium => @photo.url(:thumb_medium),
                       :image_url_small => @photo.url(:thumb_small)}
      user.update_profile(profile_params)
    end
  end
end
