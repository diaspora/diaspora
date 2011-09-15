#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.


module Jobs
  class UpdateServiceUsers < Base 
    @queue = :http_service
    def self.perform(service_id)
      service = Service.find(service_id)
      service.save_friends
    end
  end
end
