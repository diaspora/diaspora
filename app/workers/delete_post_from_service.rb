#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.
#
module Workers
  class DeletePostFromService < Base
    sidekiq_options queue: :http_service

    def perform(service_id, service_post_id)
      service = Service.find_by_id(service_id)
      service.delete_post(service_post_id)
    end
  end
end
