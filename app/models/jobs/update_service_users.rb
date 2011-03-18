#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.


module Job
  class UpdateServiceUsers < Base 
    def self.perform_delegate(service_id)
      service = Service.find(service_id)
      response = RestClient.get("https://graph.facebook.com/me/friends", {:params => {:access_token => service.access_token}})
    end
  end
end
