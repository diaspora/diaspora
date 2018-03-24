# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Workers
  class ReceivePublic < ReceiveBase
    def perform(data, legacy=false)
      filter_errors_for_retry do
        DiasporaFederation::Federation::Receiver.receive_public(data, legacy)
      end
    end
  end
end
