# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Workers
  class ReceivePrivate < ReceiveBase
    def perform(user_id, data, legacy)
      filter_errors_for_retry do
        user_private_key = User.where(id: user_id).pluck(:serialized_private_key).first
        rsa_key = OpenSSL::PKey::RSA.new(user_private_key)
        DiasporaFederation::Federation::Receiver.receive_private(data, rsa_key, user_id, legacy)
      end
    end
  end
end
