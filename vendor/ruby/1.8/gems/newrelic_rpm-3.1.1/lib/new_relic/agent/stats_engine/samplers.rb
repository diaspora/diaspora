module NewRelic
module Agent
  class StatsEngine
    module Shim # :nodoc:
      def add_sampler(*args); end
      def add_harvest_sampler(*args); end
      def start_sampler_thread(*args); end
    end
    
    # Contains statistics engine extensions to support the concept of samplers
    module Samplers

      # By default a sampler polls on harvest time, once a minute.  However you can
      # override #use_harvest_sampler? to return false and it will sample
      # every POLL_PERIOD seconds on a background thread.
      POLL_PERIOD = 20
      
      # starts the sampler thread which runs periodically, rather than
      # at harvest time. This is deprecated, and should not actually
      # be used - mo threads mo problems
      #
      # returns unless there are actually periodic samplers to run
      def start_sampler_thread

        return if @sampler_thread && @sampler_thread.alive?

        # start up a thread that will periodically poll for metric samples
        return if periodic_samplers.empty?

        @sampler_thread = Thread.new do
          while true do
            begin
              sleep POLL_PERIOD
              poll periodic_samplers
            end
          end
        end
        @sampler_thread['newrelic_label'] = 'Sampler Tasks'
      end

      private

      def add_sampler_to(sampler_array, sampler)
        raise "Sampler #{sampler.inspect} is already registered.  Don't call add_sampler directly anymore." if sampler_array.include?(sampler)
        sampler_array << sampler
        sampler.stats_engine = self
      end

      def log_added_sampler(type, sampler)
        log.debug "Adding #{type} sampler: #{sampler.inspect}"
      end

      public

      # Add an instance of Sampler to be invoked about every 10 seconds on a background
      # thread.
      def add_sampler(sampler)
        add_sampler_to(periodic_samplers, sampler)
        log_added_sampler('periodic', sampler)
      end

      # Add a sampler to be invoked just before each harvest.
      def add_harvest_sampler(sampler)
        add_sampler_to(harvest_samplers, sampler)
        log_added_sampler('harvest-time', sampler)
      end

      private

      # Call poll on each of the samplers.  Remove
      # the sampler if it raises.
      def poll(samplers)
        samplers.delete_if do |sampled_item|
          begin
            sampled_item.poll
            false # it's okay.  don't delete it.
          rescue Exception => e
            log.error "Removing #{sampled_item} from list"
            log.error e
            log.debug e.backtrace.to_s
            true # remove the sampler
          end
        end
      end

      def harvest_samplers
        @harvest_samplers ||= []
      end
      def periodic_samplers
        @periodic_samplers ||= []
      end
    end
  end
end
end
