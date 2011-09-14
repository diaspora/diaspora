#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Diaspora
  module Webhooks
    require 'builder/xchar'

    def to_diaspora_xml
      <<XML
      <XML>
      <post>#{to_xml.to_s}</post>
      </XML>
XML
    end

    def x(input)
      input.to_s.to_xs
    end

    # @abstract
    # @note this must return [Array<Person>]
    # @return [Array<Person>]
    def subscribers(user)
      raise 'You must override subscribers in order to enable federation on this model'
    end

    # @abstract
    def receive(user, person)
      raise 'You must override receive in order to enable federation on this model'
    end

    # @param [User] sender
    # @note this is a hook
    def after_dispatch sender
    end
  end
end
