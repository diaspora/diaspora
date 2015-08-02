class StatusMessageCreationService
  include Rails.application.routes.url_helpers

  attr_reader :status_message

  def initialize(params, user)
    normalize_params(params, user)
    status_message_initial = user.build_post(:status_message, params[:status_message])
    @status_message = add_attachments(params, status_message_initial)
    @status_message.save
    process_status_message(user)
  end

  private

  attr_reader :services, :destination_aspect_ids

  def normalize_params(params, user)
    normalize_aspect_ids(params)
    normalize_public_flag!(params)
    @services = [*params[:services]].compact
    @destination_aspect_ids = destination_aspect_ids(params, user)
  end

  def normalize_aspect_ids(params)
    params[:status_message][:aspect_ids] = [*params[:aspect_ids]]
  end

  def normalize_public_flag!(params)
    sm = params[:status_message]
    public_flag_string = (sm[:aspect_ids] && sm[:aspect_ids].first == "public") || sm[:public]
    public_flag = public_flag_string.to_s.match(/(true)|(on)/) ? true : false
    params[:status_message][:public] = public_flag
  end

  def destination_aspect_ids(params, user)
    if params[:status_message][:public] || params[:status_message][:aspect_ids].first == "all_aspects"
      user.aspect_ids
    else
      params[:aspect_ids]
    end
  end

  def add_attachments(params, status_message_initial)
    status_message_with_location = add_location(params, status_message_initial)
    status_message_with_poll = add_poll(params, status_message_with_location)
    add_photos(params, status_message_with_poll)
  end

  def add_location(params, status_message)
    address = params[:location_address]
    coordinates = params[:location_coords]
    status_message.build_location(address: address, coordinates: coordinates) if address.present?
    status_message
  end

  def add_poll(params, status_message)
    if params[:poll_question].present?
      status_message.build_poll(question: params[:poll_question])
      [*params[:poll_answers]].each do |poll_answer|
        status_message.poll.poll_answers.build(answer: poll_answer)
      end
    end
    status_message
  end

  def add_photos(params, status_message)
    status_message.attach_photos_by_ids(params[:photos])
    status_message
  end

  def process_status_message(user)
    add_status_message_to_streams(user)
    dispatch_status_message(user)
    user.participate!(@status_message)
  end

  def add_status_message_to_streams(user)
    aspects = user.aspects_from_ids(@destination_aspect_ids)
    user.add_to_streams(@status_message, aspects)
  end

  def dispatch_status_message(user)
    receiving_services = Service.titles(@services)
    user.dispatch_post(@status_message,
                       url:           short_post_url(@status_message.guid, host: AppConfig.environment.url),
                       service_types: receiving_services)
  end
end
