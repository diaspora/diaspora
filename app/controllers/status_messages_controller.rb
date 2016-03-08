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
        @aspect_ids = @aspects_with_person.map(&:id)
        gon.aspect_ids = @aspect_ids
        render layout: nil
      else
        @aspects_with_person = []
      end
    elsif request.format == :mobile
      @aspect = :all
      @aspects = current_user.aspects.load
      @aspect_ids = @aspects.map(&:id)
      gon.aspect_ids = @aspect_ids
    else
      redirect_to stream_path
    end
  end

  def bookmarklet
    @aspects = current_user.aspects
    @aspect_ids = current_user.aspect_ids

    gon.preloads[:bookmarklet] = {
      content: params[:content],
      title:   params[:title],
      url:     params[:url],
      notes:   params[:notes]
    }
  end

  def create
    normalized_params = params.merge(
      services:   normalize_services,
      aspect_ids: normalize_aspect_ids,
      public:     normalize_public_flag
    )
    status_message = StatusMessageCreationService.new(current_user).create(normalized_params)
    handle_mention_feedback(status_message)
    respond_to do |format|
      format.html { redirect_to :back }
      format.mobile { redirect_to stream_path }
      format.json { render json: PostPresenter.new(status_message, current_user), status: 201 }
    end
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
      format.html { redirect_to :back }
      format.mobile { redirect_to stream_path }
      format.json { render text: error.message, status: 403 }
    end
  end

  def handle_mention_feedback(status_message)
    return unless comes_from_others_profile_page?
    flash[:notice] = t("status_messages.create.success", names: status_message.mentioned_people_names)
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

  def normalize_services
    [*params[:services]].compact
  end

  def normalize_aspect_ids
    aspect_ids = [*params[:aspect_ids]]
    if aspect_ids.first == "all_aspects"
      current_user.aspect_ids
    else
      aspect_ids
    end
  end

  def normalize_public_flag
    [*params[:aspect_ids]].first == "public"
  end

  def remove_getting_started
    current_user.disable_getting_started
  end
end
