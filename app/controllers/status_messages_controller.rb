# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.
class StatusMessagesController < ApplicationController
  before_action :authenticate_user!

  before_action :remove_getting_started, only: :create

  respond_to :html, :mobile, :json

  layout "application", only: :bookmarklet

  # Called when a user clicks "Mention" on a profile page
  # @param person_id [Integer] The id of the person to be mentioned
  def new
    if params[:person_id] && fetch_person(params[:person_id])
      @aspect = :profile
      @contact = current_user.contact_for(@person)
      if @contact
        @aspects_with_person = @contact.aspects.load
        render layout: nil
      else
        @aspects_with_person = []
      end
    elsif request.format == :mobile
      @aspect = :all
      @aspects = current_user.aspects.load
    else
      redirect_to stream_path
    end
  end

  def bookmarklet
    @aspects = current_user.aspects

    gon.preloads[:bookmarklet] = {
      content: params[:content],
      title:   params[:title],
      url:     params[:url],
      notes:   params[:notes]
    }
  end

  def create
    status_message = StatusMessageCreationService.new(current_user).create(normalize_params)
    respond_to do |format|
      format.mobile { redirect_to stream_path }
      format.json { render json: PostPresenter.new(status_message, current_user), status: 201 }
    end
  rescue StatusMessageCreationService::BadAspectsIDs
    render status: 422, plain: I18n.t("status_messages.bad_aspects")
  rescue StandardError => error
    handle_create_error(error)
  end

  private

  def fetch_person(person_id)
    @person = Person.where(id: person_id).first
  end

  def handle_create_error(error)
    logger.debug error
    respond_to do |format|
      format.mobile { redirect_to stream_path }
      format.json { render plain: error.message, status: 403 }
    end
  end

  def comes_from_others_profile_page?
    coming_from_profile_page? && !own_profile_page?
  end

  def coming_from_profile_page?
    request.env["HTTP_REFERER"].include?("people")
  end

  def own_profile_page?
    request.env["HTTP_REFERER"].include?("/people/" + current_user.guid)
  end

  def normalize_params
    params.permit(
      :location_address,
      :location_coords,
      :poll_question,
      status_message: %i[text provider_display_name],
      poll_answers:   []
    ).to_h.merge(
      services:   [*params[:services]].compact,
      aspect_ids: normalize_aspect_ids,
      public:     [*params[:aspect_ids]].first == "public",
      photos:     [*params[:photos]].compact
    )
  end

  def normalize_aspect_ids
    aspect_ids = [*params[:aspect_ids]]
    if aspect_ids.first == "all_aspects"
      current_user.aspect_ids
    else
      aspect_ids
    end
  end

  def remove_getting_started
    current_user.disable_getting_started
  end
end
