require 'benchmark'
require 'abstract_controller/logger'

module ActionController
  # Adds instrumentation to several ends in ActionController::Base. It also provides
  # some hooks related with process_action, this allows an ORM like Active Record
  # and/or DataMapper to plug in ActionController and show related information.
  #
  # Check ActiveRecord::Railties::ControllerRuntime for an example.
  module Instrumentation
    extend ActiveSupport::Concern

    include AbstractController::Logger

    attr_internal :view_runtime

    def process_action(action, *args)
      raw_payload = {
        :controller => self.class.name,
        :action     => self.action_name,
        :params     => request.filtered_parameters,
        :formats    => request.formats.map(&:to_sym),
        :method     => request.method,
        :path       => (request.fullpath rescue "unknown")
      }

      ActiveSupport::Notifications.instrument("start_processing.action_controller", raw_payload.dup)

      ActiveSupport::Notifications.instrument("process_action.action_controller", raw_payload) do |payload|
        result = super
        payload[:status] = response.status
        append_info_to_payload(payload)
        result
      end
    end

    def render(*args)
      render_output = nil
      self.view_runtime = cleanup_view_runtime do
        Benchmark.ms { render_output = super }
      end
      render_output
    end

    def send_file(path, options={})
      ActiveSupport::Notifications.instrument("send_file.action_controller",
        options.merge(:path => path)) do
        super
      end
    end

    def send_data(data, options = {})
      ActiveSupport::Notifications.instrument("send_data.action_controller", options) do
        super
      end
    end

    def redirect_to(*args)
      ActiveSupport::Notifications.instrument("redirect_to.action_controller") do |payload|
        result = super
        payload[:status]   = self.status
        payload[:location] = self.location
        result
      end
    end

  protected

    # A hook which allows you to clean up any time taken into account in
    # views wrongly, like database querying time.
    #
    #   def cleanup_view_runtime
    #     super - time_taken_in_something_expensive
    #   end
    #
    # :api: plugin
    def cleanup_view_runtime #:nodoc:
      yield
    end

    # Everytime after an action is processed, this method is invoked
    # with the payload, so you can add more information.
    # :api: plugin
    def append_info_to_payload(payload) #:nodoc:
      payload[:view_runtime] = view_runtime
    end

    module ClassMethods
      # A hook which allows other frameworks to log what happened during
      # controller process action. This method should return an array
      # with the messages to be added.
      # :api: plugin
      def log_process_action(payload) #:nodoc:
        messages, view_runtime = [], payload[:view_runtime]
        messages << ("Views: %.1fms" % view_runtime.to_f) if view_runtime
        messages
      end
    end
  end
end