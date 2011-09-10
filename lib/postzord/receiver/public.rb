#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.
#
module Postzord
  class Receiver
    class Public
      attr_accessor :salmon, :author

      def initialize(xml)
        @salmon = Salmon::Slap.from_xml(xml) 
        @author = Webfinger.new(@salmon.author_email).fetch
      end

      # @return [Boolean]
      def verified_signature?
        @salmon.verified_for_key?(@author.public_key)
      end

      # @return [void]
      def perform!
        return false unless verified_signature?
        return unless save_object

        if @object.respond_to?(:relayable)
          receive_relayable
        else
          Resque.enqueue(Job::ReceiveLocalBatch, @object.id, self.recipient_user_ids)
        end
      end

      def receive_relayable
        raise RelayableObjectWithoutParent.new("Receiving a relayable object without parent object present locally!") unless @object.parent.user.present?

        # receive relayable object only for the owner of the parent object
        @object.receive(@object.parent.user, @author)

        # notify everyone who can see the parent object
        receiver = Postzord::Receiver::LocalPostBatch.new(nil, self.recipient_user_ids)
        receiver.notify_users
      end

      # @return [Object]
      def save_object
        @object = Diaspora::Parser::from_xml(@salmon.parsed_data)
        raise "Object is not public" unless @object.public?
        @object.save!
      end

      # @return [Array<Integer>] User ids
      def recipient_user_ids
        User.all_sharing_with_person(@author).select('users.id').map!{ |u| u.id }
      end

      class RelayableObjectWithoutParent < StandardError ; ; end
    end
  end
end

