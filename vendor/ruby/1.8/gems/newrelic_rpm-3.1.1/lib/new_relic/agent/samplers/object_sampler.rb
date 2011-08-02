require 'new_relic/agent/sampler'

module NewRelic
  module Agent
    module Samplers
      class ObjectSampler < NewRelic::Agent::Sampler

        def initialize
          super :objects
        end

        def stats
          stats_engine.get_stats_no_scope("GC/objects")
        end

        def self.supported_on_this_platform?
          defined?(ObjectSpace) && ObjectSpace.respond_to?(:live_objects)
        end

        def poll
          stats.record_data_point(ObjectSpace.live_objects)
        end
      end
    end
  end
end
