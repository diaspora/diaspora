#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.


class Postzord::Receiver
  require 'postzord/receiver/private'
  require 'postzord/receiver/public'
  require 'postzord/receiver/local_batch'

  def perform!
    self.receive!
  end

  def author_does_not_match_xml_author?
    if (@author.diaspora_handle != xml_author)
      FEDERATION_LOGGER.info("event=receive status=abort reason='author in xml does not match retrieved person' payload_type=#{@object.class} sender=#{@author.diaspora_handle}")
      return true
    end
  end
end

