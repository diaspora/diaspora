#   Copyright (c) 2012, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

# this module attempts to be what you need to mix into
# base level federation objects that are not relayable, and not persistable
# assumes there is an author, author_id, id,
module Diaspora
  module Federated
    module Shareable
      def self.included(model)
        model.instance_eval do
          # we are order dependant so you don't have to be!
          include Diaspora::Federated::Base
          include Diaspora::Federated::Shareable::InstanceMethods
          include Diaspora::Guid

          xml_attr :diaspora_handle
          xml_attr :public
          xml_attr :created_at
        end
      end

      module InstanceMethods
        include Diaspora::Logging
        def diaspora_handle
          author.diaspora_handle
        end

        def diaspora_handle=(author_handle)
          self.author = Person.where(diaspora_handle: author_handle).first
        end

        # The list of people that should receive this Shareable.
        #
        # @return [Array<Person>] The list of subscribers to this shareable
        def subscribers
          user = author.owner
          if public?
            user.contact_people
          else
            user.people_in_aspects(user.aspects_with_shareable(self.class, id))
          end
        end
      end
    end
  end
end
