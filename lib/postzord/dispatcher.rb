#   Copyright (c) 2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.


class Postzord::Dispatcher
  require File.join(Rails.root, 'lib/postzord/dispatcher/private')
  #require File.join(Rails.root, 'lib/postzord/dispatcher/public')

  attr_reader :zord
  delegate :post, :to => :zord

  def initialize(user, object, opts={})
    unless object.respond_to? :to_diaspora_xml
      raise 'this object does not respond_to? to_diaspora xml.  try including Diaspora::Webhooks into your object'
    end

    #if object.respond_to?(:public) && object.public?
    #  Postzord::Dispatcher::Public.new(user, object, opts)
    #else
     @zord =  Postzord::Dispatcher::Private.new(user, object, opts)
    #end
  end
end

