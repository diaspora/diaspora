# TODO: Add likes, comments, photos, polls, etc

module Api
  module V0
    class PostResource < JSONAPI::Resource
      include Rails.application.routes.url_helpers

      model_name "StatusMessage"
      attributes :guid, :public, :pending, :created_at, :interacted_at, :provider_display_name,
                 :image_url, :object_url, :post_type, :nsfw, :raw_message
      has_one :author

      def self.find_by_key(key, options)
        post = Post.find_non_public_by_guid_or_id_with_user(key, options[:context][:current_user])
        resource_for_model(post).new(post, context)
      rescue ActiveRecord::RecordNotFound
        raise JSONAPI::Exceptions::RecordNotFound.new(key) if post.nil?
      end

      before_save :add_author
      after_save :process_status_message

      def add_author
        @model.author = context[:current_user].person
        @model.diaspora_handle = context[:current_user].person.diaspora_handle
      end

      def process_status_message
        user = context[:current_user]
        destination_aspect_ids = context[:aspect_ids]
        add_status_message_to_streams(user, destination_aspect_ids)
        dispatch_status_message(user)
        user.participate!(@model)
      end

      def add_status_message_to_streams(user, destination_aspect_ids)
        aspects = user.aspects_from_ids(destination_aspect_ids)
        user.add_to_streams(@model, aspects)
      end

      def dispatch_status_message(user)
        @services = [] # TODO: Replace with real services
        receiving_services = Service.titles(@services)
        user.dispatch_post(@model, url:           short_post_url(@model.guid, host: AppConfig.environment.url),
                                   service_types: receiving_services)
      end
    end
  end
end
