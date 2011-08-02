require 'new_relic/agent/instrumentation'
module NewRelic
  module Agent
    module Instrumentation
      class MetricFrame
        module Pop

          def clear_thread_metric_frame!
            Thread.current[:newrelic_metric_frame] = nil
          end

          def set_new_scope!(metric)
            agent.stats_engine.scope_name = metric
          end

          def log_underflow
            NewRelic::Agent.logger.error "Underflow in metric frames: #{caller.join("\n   ")}"
          end

          def notice_scope_empty
            transaction_sampler.notice_scope_empty
          end

          def record_transaction_cpu
            burn = cpu_burn
            transaction_sampler.notice_transaction_cpu_time(burn) if burn
          end

          def normal_cpu_burn
            return unless @process_cpu_start
            process_cpu - @process_cpu_start
          end

          def jruby_cpu_burn
            return unless @jruby_cpu_start
            burn = (jruby_cpu_time - @jruby_cpu_start)
            record_jruby_cpu_burn(burn)
            burn
          end

          # we need to do this here because the normal cpu sampler
          # process doesn't work on JRuby. See the cpu_sampler.rb file
          # to understand where cpu is recorded for non-jruby processes
          def record_jruby_cpu_burn(burn)
            NewRelic::Agent.get_stats_no_scope(NewRelic::Metrics::USER_TIME).record_data_point(burn)
          end

          def cpu_burn
            normal_cpu_burn || jruby_cpu_burn
          end

          def end_transaction!
            agent.stats_engine.end_transaction
          end

          def notify_transaction_sampler(web_transaction)
            record_transaction_cpu
            notice_scope_empty
          end

          def traced?
            NewRelic::Agent.is_execution_traced?
          end

          def handle_empty_path_stack(metric)
            raise 'path stack not empty' unless @path_stack.empty?
            notify_transaction_sampler(metric.is_web_transaction?) if traced?
            end_transaction!
            clear_thread_metric_frame!
          end

          def current_stack_metric
            metric_name
          end
        end
      end
    end
  end
end
