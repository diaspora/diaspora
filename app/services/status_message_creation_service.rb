# frozen_string_literal: true

class StatusMessageCreationService
  include Rails.application.routes.url_helpers

  def initialize(user)
    @user = user
  end

  def create(params)
    validate_content(params)

    build_status_message(params).tap do |status_message|
      load_aspects(params[:aspect_ids]) unless status_message.public?
      add_attachments(status_message, params)
      status_message.save
      process(status_message, params[:services])
    end
  end

  private

  attr_reader :user, :aspects

  def validate_content(params)
    raise MissingContent unless params[:status_message][:text].present? || params[:photos].present?
  end

  def build_status_message(params)
    public = params[:public] || false
    user.build_post(:status_message, params[:status_message].merge(public: public))
  end

  def add_attachments(status_message, params)
    add_location(status_message, params[:location_address], params[:location_coords])
    add_poll(status_message, params)
    add_photos(status_message, params[:photos])
  end

  def add_location(status_message, address, coordinates)
    status_message.build_location(address: address, coordinates: coordinates) if address.present?
  end

  def add_poll(status_message, params)
    if params[:poll_question].present?
      status_message.build_poll(question: params[:poll_question])
      [*params[:poll_answers]].each do |poll_answer|
        answer = status_message.poll.poll_answers.build(answer: poll_answer)
        answer.poll = status_message.poll
      end
    end
  end

  def add_photos(status_message, photos)
    if photos.present?
      status_message.photos << Photo.where(id: photos, author_id: status_message.author_id)
      status_message.photos.each do |photo|
        photo.public = status_message.public
        photo.pending = false
      end
    end
  end

  def load_aspects(aspect_ids)
    @aspects = user.aspects_from_ids(aspect_ids)
    raise BadAspectsIDs if aspects.empty?
  end

  def process(status_message, services)
    add_to_streams(status_message) unless status_message.public?
    dispatch(status_message, services)
  end

  def add_to_streams(status_message)
    user.add_to_streams(status_message, aspects)
    status_message.photos.each {|photo| user.add_to_streams(photo, aspects) }
  end

  def dispatch(status_message, services)
    receiving_services = services ? Service.titles(services) : []
    status_message.filter_mentions # this is only required until changes from #6818 are deployed on every pod
    user.dispatch_post(status_message,
                       url:           short_post_url(status_message.guid, host: AppConfig.environment.url),
                       service_types: receiving_services)
  end

  class BadAspectsIDs < RuntimeError
  end

  class MissingContent < RuntimeError
  end
end
