class ActionView::LogSubscriber

  # In order to be more friendly to Splunk, which we use for log analysis,
  # we override a few logging methods.  There are not overriden if enable_splunk_logging is set to false in config/application.yml
  def render_template(event)
    count = event.payload[:count] || 1
    hash = {:event    => :render,
            :template => from_rails_root(event.payload[:identifier]),
            :total_ms => event.duration,
            :count    => count,
            :ms       => event.duration / count}

    hash.merge(:layout => event.payload[:layout]) if event.payload[:layout]

    Rails.logger.info(hash)
  end
  alias :render_partial :render_template
  alias :render_collection :render_template
end

module ActionDispatch
  class ShowExceptions
    private
      # This override logs in a format Splunk can more easily understand.
      # @see ActionView::LogSubscriber#render_template
      def log_error(exception)
        return unless logger

        ActiveSupport::Deprecation.silence do
          message = "event=error error_class=#{exception.class} error_message='#{exception.message}' "
          message << "gc_ms=#{GC.time/1000} gc_collections=#{GC.collections} gc_bytes=#{GC.growth} " if GC.respond_to?(:enable_stats)
          message << "orig_error_message='#{exception.original_exception.message}'" if exception.respond_to?(:original_exception)
          message << "annotated_source='#{exception.annoted_source_code.to_s}' " if exception.respond_to?(:annoted_source_code)
          message << "app_backtrace='#{application_trace(exception).join(";")}'"
          logger.fatal("\n\n#{message}\n\n")
        end
      end
  end
end

class ActionController::LogSubscriber
  require "#{File.dirname(__FILE__)}/active_record_instantiation_logs.rb"
  include Oink::InstanceTypeCounter
  def start_processing(event)
    #noop
  end

  # This override logs in a format Splunk can more easily understand.
  # @see ActionView::LogSubscriber#render_template
  def process_action(event)
    payload   = event.payload
    additions = ActionController::Base.log_process_action(payload)
    params  = payload[:params].except(*INTERNAL_PARAMS)

    log_hash = {:event => :request_completed,
                :status => payload[:status],
                :controller => payload[:controller],
                :action => payload[:action],
                :format => payload[:formats].first.to_s.upcase,
                :ms => ("%.0f" % event.duration).to_i,
                :params => params.inspect}
    log_hash.merge!({
                :gc_ms => GC.time/1000,
                :gc_collections => GC.collections,
                :gc_bytes=> GC.growth}) if GC.respond_to?(:enable_stats)

    log_hash.merge!({:view_ms => payload[:view_runtime],
                     :db_ms => payload[:db_runtime]}) unless additions.blank?
    log_hash.merge!(report_hash!)

    Rails.logger.info(log_hash)
  end
end

module Rails
  module Rack
    class Logger
      # This override logs in a format Splunk can more easily understand.
      # @see ActionView::LogSubscriber#render_template
      def before_dispatch(env)
        request = ActionDispatch::Request.new(env)
        path = request.fullpath

        Rails.logger.info("event=request_started verb=#{env["REQUEST_METHOD"]} path=#{path} ip=#{request.ip} ")
      end
    end
  end
end
