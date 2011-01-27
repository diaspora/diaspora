class ActionView::LogSubscriber
  def render_template(event)
    message = "event=render "
    message << "template=#{from_rails_root(event.payload[:identifier])} "
    message << "layout=#{from_rails_root(event.payload[:layout])} " if event.payload[:layout]
    message << "ms=#{("%.1f" % event.duration)} "
    #message << "r_id=#{event.transaction_id} "
    Rails.logger.info(message)
  end
  alias :render_partial :render_template
  alias :render_collection :render_template
end

module ActionDispatch
  class ShowExceptions
    private
      def log_error(exception)
        return unless logger

        ActiveSupport::Deprecation.silence do
          message = "event=error error_class=#{exception.class} error_message='#{exception.message}' "
          message << "orig_error_message='#{exception.original_exception.message}'" if exception.respond_to?(:original_exception)
          message << "annotated_source='#{exception.annoted_source_code.to_s}' " if exception.respond_to?(:annoted_source_code)
          message << "app_backtrace='#{application_trace(exception).join(";")}'"
          logger.fatal("\n\n#{message}\n\n")
        end
      end
  end
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
    #log_string << "additions='#{additions.join(" | ")}' " unless additions.blank?

    Rails.logger.info(log_string)
  end
end

module Rails
  module Rack
    class Logger
      def before_dispatch(env)
        request = ActionDispatch::Request.new(env)
        path = request.fullpath

        Rails.logger.info("event=request_started verb=#{env["REQUEST_METHOD"]} path=#{path} ip=#{request.ip} ")
      end
    end
  end
end
