# A Sampler is used to capture meaningful metrics in a background thread
# periodically.  They will either be invoked once a minute just before the
# data is sent to the agent (default) or every 10 seconds, when #use_harvest_sampler?
# returns false.
#
# Samplers can be added to New Relic by subclassing NewRelic::Agent::Sampler.
# Instances are created when the agent is enabled and installed.  Subclasses
# are registered for instantiation automatically.
module NewRelic
  module Agent
    class Sampler

      # Exception denotes a sampler is not available and it will not be registered.
      class Unsupported < StandardError;  end

      attr_accessor :stats_engine
      attr_reader :id
      @sampler_classes = []

      def self.inherited(subclass)
        @sampler_classes << subclass
      end

      # Override with check.  Called before instantiating.
      def self.supported_on_this_platform?
        true
      end

      # Override to use the periodic sampler instead of running the sampler on the
      # minute during harvests.
      def self.use_harvest_sampler?
        true
      end

      def self.sampler_classes
        @sampler_classes
      end

      def initialize(id)
        @id = id
      end

      def poll
        raise "Implement in the subclass"
      end


    end
  end
end
