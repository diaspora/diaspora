#   Copyright (c) 2010-2012, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

#the base level federation contract, which right now means that the object
#can be serialized and deserialized from xml, and respond to methods
#in the federation flow


#including this module lets you federate an object at the most basic of level

module Diaspora
  module Federated
    module Base 
      def self.included(model)
        model.instance_eval do
          include ROXML
          include Diaspora::Federated::Base::InstanceMethods
        end
      end

      module InstanceMethods
        def to_diaspora_xml
          <<-XML
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
        # @note this is a hook(optional)
        def after_dispatch(sender)
        end
      end
    end
  end
end
