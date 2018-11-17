# frozen_string_literal: true

module Api
  module V1
    class ContactsController < Api::V1::BaseController
      before_action only: %i[index] do
        require_access_token %w[read]
      end

      before_action only: %i[create destroy] do
        require_access_token %w[read write]
      end

      rescue_from ActiveRecord::RecordNotFound do
        render json: I18n.t("api.endpoint_errors.aspects.not_found"), status: :not_found
      end

      def index
        contacts = aspects_membership_service.contacts_in_aspect(params[:aspect_id])
        render json: contacts.map {|c| ContactPresenter.new(c, current_user).as_api_json_without_contact }
      end

      def create
        aspect_id = params[:aspect_id]
        person = Person.find_by(guid: params[:person_guid])
        aspect_membership = aspects_membership_service.create(aspect_id, person.id) if person.present?
        if aspect_membership
          head :no_content
        else
          render json: I18n.t("api.endpoint_errors.contacts.cant_create"), status: :unprocessable_entity
        end
      rescue ActiveRecord::RecordNotUnique
        render json: I18n.t("api.endpoint_errors.contacts.cant_create"), status: :unprocessable_entity
      end

      def destroy
        aspect_id = params[:aspect_id]
        person = Person.find_by(guid: params[:id])
        result = aspects_membership_service.destroy_by_ids(aspect_id, person.id) if person.present?
        if result && result[:success]
          head :no_content
        else
          render json: I18n.t("api.endpoint_errors.contacts.cant_delete"), status: :unprocessable_entity
        end
      rescue ActiveRecord::RecordNotFound
        render json: I18n.t("api.endpoint_errors.contacts.not_found"), status: :not_found
      end

      def aspects_membership_service
        AspectsMembershipService.new(current_user)
      end
    end
  end
end
