module NewRelic
  module Agent
    module Instrumentation
      module ActiveRecordInstrumentation

        def self.included(instrumented_class)
          instrumented_class.class_eval do
            unless instrumented_class.method_defined?(:log_without_newrelic_instrumentation)
              alias_method :log_without_newrelic_instrumentation, :log
              alias_method :log, :log_with_newrelic_instrumentation
              protected :log
            end
          end
        end

        def log_with_newrelic_instrumentation(*args, &block)

          return log_without_newrelic_instrumentation(*args, &block) unless NewRelic::Agent.is_execution_traced?

          sql, name, binds = args

          # Capture db config if we are going to try to get the explain plans
          if (defined?(ActiveRecord::ConnectionAdapters::MysqlAdapter) && self.is_a?(ActiveRecord::ConnectionAdapters::MysqlAdapter)) ||
              (defined?(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter) && self.is_a?(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter))
            supported_config = @config
          end
          if name && (parts = name.split " ") && parts.size == 2
            model = parts.first
            operation = parts.last.downcase
            metric_name = case operation
                          when 'load', 'count', 'exists' then 'find'
                          when 'indexes', 'columns' then nil # fall back to DirectSQL
                          when 'destroy', 'find', 'save', 'create' then operation
                          when 'update' then 'save'
                          else
                            if model == 'Join'
                              operation
                            end
                          end
            metric = "ActiveRecord/#{model}/#{metric_name}" if metric_name
          end

          if metric.nil?
            metric = NewRelic::Agent::Instrumentation::MetricFrame.database_metric_name
            if metric.nil?
              if sql =~ /^(select|update|insert|delete|show)/i
                # Could not determine the model/operation so let's find a better
                # metric.  If it doesn't match the regex, it's probably a show
                # command or some DDL which we'll ignore.
                metric = "Database/SQL/#{$1.downcase}"
              else
                metric = "Database/SQL/other"
              end
            end
          end

          if !metric
            log_without_newrelic_instrumentation(*args, &block)
          else
            metrics = [metric, "ActiveRecord/all"]
            metrics << "ActiveRecord/#{metric_name}" if metric_name
            self.class.trace_execution_scoped(metrics) do
              sql, name, binds = args
              t0 = Time.now
              begin
                log_without_newrelic_instrumentation(*args, &block)
              ensure
                NewRelic::Agent.instance.transaction_sampler.notice_sql(sql, supported_config, (Time.now - t0).to_f)
              end
            end
          end
        end

      end
    end
  end
end

DependencyDetection.defer do
  depends_on do
    defined?(ActiveRecord) && defined?(ActiveRecord::Base)
  end

  depends_on do
    defined?(Rails) && Rails::VERSION::MAJOR.to_i == 3
  end

  depends_on do
    !NewRelic::Control.instance['skip_ar_instrumentation']
  end

  depends_on do
    !NewRelic::Control.instance['disable_activerecord_instrumentation']
  end
  
  executes do
    NewRelic::Agent.logger.debug 'Installing Rails3 ActiveRecord instrumentation'
  end
  
  executes do
    Rails.configuration.after_initialize do
      ActiveRecord::ConnectionAdapters::AbstractAdapter.module_eval do
        include ::NewRelic::Agent::Instrumentation::ActiveRecordInstrumentation
      end
    end
  end

  executes do
    Rails.configuration.after_initialize do
      ActiveRecord::Base.class_eval do
        class << self
          add_method_tracer :find_by_sql, 'ActiveRecord/#{self.name}/find_by_sql', :metric => false
          add_method_tracer :transaction, 'ActiveRecord/#{self.name}/transaction', :metric => false
        end
      end
    end
  end
end
