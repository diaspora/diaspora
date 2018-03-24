# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.
#
module Workers
  class DeletePostFromService < Base
    sidekiq_options queue: :high

    def perform(service_id, opts)
      service = Service.find_by_id(service_id)
      opts = ActiveSupport::HashWithIndifferentAccess.new(opts)
      service.delete_from_service(opts)
    end
  end
end
