#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.


class Postzord::Receiver
  include Diaspora::Logging

  require 'postzord/receiver/private'
  require 'postzord/receiver/public'
  require 'postzord/receiver/local_batch'

  def perform!
    self.receive!
  end

  private

  def author_does_not_match_xml_author?
    return false unless @author.diaspora_handle != xml_author
    logger.error "event=receive status=abort reason='author in xml does not match retrieved person' " \
                 "type=#{@object.class} sender=#{@author.diaspora_handle}"
    true
  end

  def relayable_without_parent?
    return false unless @object.respond_to?(:relayable?) && @object.parent.nil?
    logger.error "event=receive status=abort reason='no corresponding post' type=#{@object.class} " \
                 "sender=#{@author.diaspora_handle}"
    true
  end
end
