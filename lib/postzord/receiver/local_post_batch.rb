module Postzord
  module Receiver
    class LocalPostBatch
      attr_reader :post, :recipient_user_ids, :users

      def initialize(post, recipient_user_ids)
        @post = post
        @recipient_user_ids = recipient_user_ids
        @users = User.where(:id => @recipient_user_ids)
      end

      def perform!
        create_visibilities
        socket_to_users if @post.respond_to?(:socket_to_user)
        notify_mentioned_users
        notify_users
      end

      # Batch import visibilities for the recipients of the given @post
      # @note performs a bulk insert into mySQL
      # @return [void]
      def create_visibilities
        contacts = Contact.where(:user_id => @recipient_user_ids, :person_id => @post.author_id)
        PostVisibility.batch_import(contacts, post)
      end

      # Issue websocket requests to all specified recipients
      # @return [void]
      def socket_to_users
        @users.each do |user|
          @post.socket_to_user(user)
        end
      end

      # Notify any mentioned users within the @post's text
      # @return [void]
      def notify_mentioned_users
        @post.mentions.each do |mention|
          mention.notify_recipient
        end
      end

      # Notify users of the new post
      # return [void]
      def notify_users
        return unless @post.respond_to?(:notification_type) 
        @users.each do |user|
          Notification.notify(user, @post, @post.author)
        end
      end
    end
  end
end
