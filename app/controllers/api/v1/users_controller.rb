# frozen_string_literal: true

module Api
  module V1
    class UsersController < Api::V1::BaseController
      include TagsHelper

      before_action except: %i[update] do
        require_access_token %w[read]
      end

      before_action only: %i[update] do
        require_access_token %w[write]
      end

      rescue_from ActiveRecord::RecordNotFound do
        render json: I18n.t("api.endpoint_errors.users.not_found"), status: :not_found
      end

      def show
        person = if params.has_key?(:id)
                   Person.find_by!(guid: params[:id])
                 else
                   current_user.person
                 end
        render json: PersonPresenter.new(person, current_user).profile_hash_as_api_json
      end

      def update
        raise RuntimeError if params.has_key?(:id)
        params_to_update = profile_update_params
        if params_to_update && current_user.update_profile(params_to_update)
          render json: PersonPresenter.new(current_user.person, current_user).profile_hash_as_api_json
        else
          render json: I18n.t("api.endpoint_errors.users.cant_update"), status: :unprocessable_entity
        end
      rescue RuntimeError
        render json: I18n.t("api.endpoint_errors.users.cant_update"), status: :unprocessable_entity
      end

      def contacts
        if params[:user_id] != current_user.guid
          render json: I18n.t("api.endpoint_errors.users.not_found"), status: :not_found
          return
        end

        contacts_with_profile = AspectsMembershipService.new(current_user).all_contacts
        render json: contacts_with_profile.map {|c| PersonPresenter.new(c.person).as_api_json }
      end

      def photos
        person = Person.find_by!(guid: params[:user_id])
        photos = Photo.visible(current_user, person, :all, Time.current)
        render json: photos.map {|photo| PhotoPresenter.new(photo).as_api_json(false) }
      end

      def posts
        person = Person.find_by!(guid: params[:user_id])
        posts = current_user.posts_from(person)
        render json: posts.map {|post| PostPresenter.new(post, current_user).as_api_response }
      end

      private

      def profile_update_params
        updates = params.permit(:bio, :birthday, :gender, :location, :first_name, :last_name,
                                :searchable, :show_profile_info, :nsfw, :tags).to_h || {}
        if updates.has_key?(:show_profile_info)
          updates[:public_details] = updates[:show_profile_info]
          updates.delete(:show_profile_info)
        end
        process_tags_updates(updates)
        updates
      end

      def process_tags_updates(updates)
        return unless params.has_key?(:tags)
        raise RuntimeError if params[:tags].length > Profile::MAX_TAGS
        tags = params[:tags].map {|tag| "#" + normalize_tag_name(tag) }.join(" ")
        updates[:tag_string] = tags
        updates.delete(:tags)
      end
    end
  end
end
