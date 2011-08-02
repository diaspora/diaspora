# FIXME: this should be a separate dependency block for each kind of
# view instrumentation
DependencyDetection.defer do
  depends_on do
    defined?(ActionController) && defined?(ActionController::Base)
  end

  depends_on do
    defined?(Rails) && Rails::VERSION::MAJOR.to_i == 2
  end

  depends_on do
    !NewRelic::Control.instance['disable_view_instrumentation']
  end

  executes do    
    case Rails::VERSION::STRING

    when /^(1\.|2\.0)/  # Rails 1.* - 2.0
      ActionController::Base.class_eval do
        add_method_tracer :render, 'View/#{newrelic_metric_path}/Rendering'
      end

    when /^2\.1\./  # Rails 2.1
      ActionView::PartialTemplate.class_eval do
        add_method_tracer :render, 'View/#{path_without_extension[%r{^(/.*/)?(.*)$},2]}.#{@view.template_format}.#{extension}/Partial'
      end
      # this is for template rendering, as opposed to partial rendering.
      ActionView::Template.class_eval do
        add_method_tracer :render, 'View/#{(path_without_extension || @view.controller.newrelic_metric_path)[%r{^(/.*/)?(.*)$},2]}.#{@view.template_format}.#{extension}/Rendering'
      end

    when /^2\./   # Rails 2.2-2.*
      ActionView::RenderablePartial.module_eval do
        add_method_tracer :render_partial, 'View/#{path[%r{^(/.*/)?(.*)$},2]}/Partial'
      end
      ActionView::Template.class_eval do
        add_method_tracer :render, 'View/#{path[%r{^(/.*/)?(.*)$},2]}/Rendering'
      end
    end
  end
end

DependencyDetection.defer do
  depends_on do
    defined?(ActionController) && defined?(ActionController::Base)
  end

  depends_on do
    defined?(Rails) && Rails::VERSION::MAJOR.to_i == 2
  end
  
  executes do
    NewRelic::Agent.logger.debug 'Installing Rails Controller instrumentation'
  end

  executes do
    ActionController::Base.class_eval do
      include NewRelic::Agent::Instrumentation::ControllerInstrumentation

      # Compare with #alias_method_chain, which is not available in
      # Rails 1.1:
      alias_method :perform_action_without_newrelic_trace, :perform_action
      alias_method :perform_action, :perform_action_with_newrelic_trace
      private :perform_action

      def self.newrelic_write_attr(attr_name, value) # :nodoc:
        write_inheritable_attribute(attr_name, value)
      end

      def self.newrelic_read_attr(attr_name) # :nodoc:
        read_inheritable_attribute(attr_name)
      end

      # determine the path that is used in the metric name for
      # the called controller action
      def newrelic_metric_path(action_name_override = nil)
        action_part = action_name_override || action_name
        if action_name_override || self.class.action_methods.include?(action_part)
          "#{self.class.controller_path}/#{action_part}"
        else
          "#{self.class.controller_path}/(other)"
        end
      end
    end
  end
end
