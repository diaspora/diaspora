# frozen_string_literal: true

require "api/paging/index_paginator"

module Api
  module V1
    class ContactsController < Api::V1::BaseController
      before_action except: %i[create destroy] do
        require_access_token %w[contacts:read]
      end

      before_action only: %i[create destroy] do
        require_access_token %w[contacts:modify]
      end

      rescue_from ActiveRecord::RecordNotFound do
        render json: I18n.t("api.endpoint_errors.aspects.not_found"), status: :not_found
      end

      def index
        contacts_query = aspects_membership_service.contacts_in_aspect(params.require(:aspect_id))
        contacts_page = index_pager(contacts_query).response
        contacts_page[:data] = contacts_page[:data].map do |c|
          ContactPresenter.new(c, current_user).as_api_json_without_contact
        end
        render_paged_api_response contacts_page
      end

      def create
        aspect_id = params.require(:aspect_id)
        person = Person.find_by(guid: params.require(:person_guid))
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
        aspect_id = params.require(:aspect_id)
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
