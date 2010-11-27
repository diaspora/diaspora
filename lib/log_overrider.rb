class ActionView::LogSubscriber
  def render_template(event)
    message = "event=render "
    message << "template=#{from_rails_root(event.payload[:identifier])} "
    message << "layout=#{from_rails_root(event.payload[:layout])} " if event.payload[:layout]
    message << "ms=#{("%.1f" % event.duration)}"
    Rails.logger.info(message)
  end
  alias :render_partial :render_template
  alias :render_collection :render_template
end

class ActionController::LogSubscriber
  def start_processing(event)
    #noop
  end

  def process_action(event)
    payload   = event.payload
    additions = ActionController::Base.log_process_action(payload)
    params  = payload[:params].except(*INTERNAL_PARAMS)

    log_string = "event=request_completed status=#{payload[:status]} "
    log_string << "controller=#{payload[:controller]} action=#{payload[:action]} format=#{payload[:formats].first.to_s.upcase} "
    log_string << "ms=#{"%.0f" % event.duration} "
    log_string << "params='#{params.inspect}' " unless params.empty?
    log_string << "additions='#{additions.join(" | ")}'" unless additions.blank?

    Rails.logger.info(log_string)
  end
end
