require 'new_relic/collection_helper'
require 'new_relic/transaction_sample'
require 'new_relic/control'
require 'new_relic/agent/instrumentation/metric_frame'
module NewRelic
  module Agent
    # a builder is created with every sampled transaction, to dynamically
    # generate the sampled data.  It is a thread-local object, and is not
    # accessed by any other thread so no need for synchronization.
    class TransactionSampleBuilder
      attr_reader :current_segment, :sample

      include NewRelic::CollectionHelper

      def initialize(time=Time.now)
        @sample = NewRelic::TransactionSample.new(time.to_f)
        @sample_start = time.to_f
        @current_segment = @sample.root_segment
      end

      def sample_id
        @sample.sample_id
      end
      def ignored?
        @ignore || @sample.params[:path].nil?
      end
      def ignore_transaction
        @ignore = true
      end
      def trace_entry(metric_name, time)
        segment = @sample.create_segment(time.to_f - @sample_start, metric_name)
        @current_segment.add_called_segment(segment)
        @current_segment = segment
      end

      def trace_exit(metric_name, time)
        if metric_name != @current_segment.metric_name
          fail "unbalanced entry/exit: #{metric_name} != #{@current_segment.metric_name}"
        end
        @current_segment.end_trace(time.to_f - @sample_start)
        @current_segment = @current_segment.parent_segment
      end

      def finish_trace(time)
        # This should never get called twice, but in a rare case that we can't reproduce in house it does.
        # log forensics and return gracefully
        if @sample.frozen?
          log = NewRelic::Control.instance.log
          log.error "Unexpected double-freeze of Transaction Trace Object: \n#{@sample.to_s}"
          return
        end
        @sample.root_segment.end_trace(time.to_f - @sample_start)
        @sample.params[:custom_params] = normalize_params(NewRelic::Agent::Instrumentation::MetricFrame.custom_parameters)
        @sample.freeze
        @current_segment = nil
      end

      def scope_depth
        depth = -1        # have to account for the root
        current = @current_segment

        while(current)
          depth += 1
          current = current.parent_segment
        end

        depth
      end

      def freeze
        @sample.freeze unless sample.frozen?
      end

      def set_profile(profile)
        @sample.profile = profile
      end

      def set_transaction_info(path, uri, params)
        @sample.params[:path] = path

        if NewRelic::Control.instance.capture_params
          params = normalize_params params

          @sample.params[:request_params].merge!(params)
          @sample.params[:request_params].delete :controller
          @sample.params[:request_params].delete :action
        end
        @sample.params[:uri] ||= uri || params[:uri]
      end

      def set_transaction_cpu_time(cpu_time)
        @sample.params[:cpu_time] = cpu_time
      end

      def sample
        @sample
      end

    end
  end
end
