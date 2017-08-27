# frozen_string_literal: true

# Copyright (c) 2010-2011, Diaspora Inc.  This file is
# licensed under the Affero General Public License version 3 or later.  See
# the COPYRIGHT file.

if AppConfig.environment.certificate_authorities.blank? && (Rails.env == "development")
  module OpenSSL
    module SSL
      remove_const :VERIFY_PEER
    end
  end
  OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
end


