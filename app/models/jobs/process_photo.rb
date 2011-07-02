#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.


module Job
  class ProcessPhoto < Base
    @queue = :photos
    def self.perform_delegate(photo_id)
      Photo.find(photo_id).process
    end
  end
end
