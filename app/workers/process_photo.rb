#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.


module Workers
  class ProcessPhoto < Base
    sidekiq_options queue: :photos

    def perform(id)
      photo = Photo.find(id)
      unprocessed_image = photo.unprocessed_image

      return false if photo.processed? || unprocessed_image.path.try(:include?, ".gif")

      photo.processed_image.store!(unprocessed_image)

      photo.save!
    end
  end
end
