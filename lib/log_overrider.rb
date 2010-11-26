class ActionView::LogSubscriber
  def render_template(event)
    message = "event=render "
    message << "template=#{from_rails_root(event.payload[:identifier])} "
    message << "layout=#{from_rails_root(event.payload[:layout])} " if event.payload[:layout]
    message << "time=#{("%.1fms" % event.duration)}"
    info(message)
  end
  alias :render_partial :render_template
  alias :render_collection :render_template
end

class ActionController::LogSubscriber
  def start_processing(event)
    payload = event.payload
    params  = payload[:params].except(*INTERNAL_PARAMS)
    log_string = "event=request_routed controller=#{payload[:controller]} action=#{payload[:action]} format=#{payload[:formats].first.to_s.upcase} "
    log_string << "params='#{params.inspect}'" unless params.empty?
    info(log_string)
  end

  def process_action(event)
    payload   = event.payload
    additions = ActionController::Base.log_process_action(payload)

    log_string = "event=request_completed status=#{payload[:status]} "
    log_string << "hstatus=#{Rack::Utils::HTTP_STATUS_CODES[payload[:status]]} time=#{"%.0fms" % event.duration} "
    log_string << " (#{additions.join(" | ")})" unless additions.blank?

    info(log_string)
  end
end
