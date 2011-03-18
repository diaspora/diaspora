#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.


module Job
  class UpdateServiceUsers < Base 
    def self.perform_delegate(service_id)
      service = Service.find(service_id)
      service.save_friends
    end
  end
end
