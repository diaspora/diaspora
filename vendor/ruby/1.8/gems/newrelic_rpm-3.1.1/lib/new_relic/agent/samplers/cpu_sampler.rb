require 'new_relic/agent/sampler'

module NewRelic
  module Agent
    module Samplers
      class CpuSampler < NewRelic::Agent::Sampler
        attr_reader :last_time
        def initialize
          super :cpu
          poll
        end

        def user_util_stats
          stats_engine.get_stats_no_scope("CPU/User/Utilization")
        end
        def system_util_stats
          stats_engine.get_stats_no_scope("CPU/System/Utilization")
        end
        def usertime_stats
          stats_engine.get_stats_no_scope("CPU/User Time")
        end
        def systemtime_stats
          stats_engine.get_stats_no_scope("CPU/System Time")
        end

        def self.supported_on_this_platform?
          # Process.times on JRuby reports wall clock elapsed time,
          # not actual cpu time used, so we cannot use this sampler there.
          not defined?(JRuby)
        end

        def poll
          now = Time.now
          t = Process.times
          if @last_time
            elapsed = now - @last_time
            return if elapsed < 1 # Causing some kind of math underflow
            num_processors = NewRelic::Control.instance.local_env.processors || 1
            usertime = t.utime - @last_utime
            systemtime = t.stime - @last_stime

            systemtime_stats.record_data_point(systemtime) if systemtime >= 0
            usertime_stats.record_data_point(usertime) if usertime >= 0

            # Calculate the true utilization by taking cpu times and dividing by
            # elapsed time X num_processors.
            user_util_stats.record_data_point usertime / (elapsed * num_processors)
            system_util_stats.record_data_point systemtime / (elapsed * num_processors)
          end
          @last_utime = t.utime
          @last_stime = t.stime
          @last_time = now
        end
      end
    end
  end
end

