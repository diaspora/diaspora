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
      def before_dispatch(env)
        request = ActionDispatch::Request.new(env)
        path = request.fullpath

        Rails.logger.info("event=request_started verb=#{env["REQUEST_METHOD"]} path=#{path} ip=#{request.ip} ")
      end
    end
  end
end

module ActiveRecord
  class LogSubscriber
    def sql(event)
      self.class.runtime += event.duration
      return unless logger.info?

      payload = event.payload
      sql     = payload[:sql].squeeze(' ')
      binds   = nil

      unless (payload[:binds] || []).empty?
        binds = "  " + payload[:binds].map { |col,v|
          [col.name, v]
        }.inspect
      end

      log_string = "event=sql name='#{payload[:name]}' ms=#{event.duration} query='#{sql}'"
      log_string << "caller_hash=#{caller.hash} binds='#{binds}' caller_with_diaspora='#{caller.grep(/diaspora\/(app|lib)/).join(';')}'"
      info log_string

    end
  end
end
