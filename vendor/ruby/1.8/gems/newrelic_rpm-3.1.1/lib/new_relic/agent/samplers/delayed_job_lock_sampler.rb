require 'new_relic/agent/sampler'
require 'new_relic/delayed_job_injection'

module NewRelic
  module Agent
    module Samplers
      class DelayedJobLockSampler < NewRelic::Agent::Sampler
        def initialize
          super :delayed_job_lock
          raise Unsupported, "DJ instrumentation disabled" if NewRelic::Control.instance['disable_dj']
          raise Unsupported, "No DJ worker present" unless NewRelic::DelayedJobInjection.worker_name
        end

        def stats
          stats_engine.get_stats("Custom/DJ Locked Jobs", false)
        end

        def local_env
          NewRelic::Control.instance.local_env
        end

        def worker_name
          local_env.dispatcher_instance_id
        end

        def locked_jobs
          Delayed::Job.count(:conditions => {:locked_by => NewRelic::DelayedJobInjection.worker_name})
        end

        def self.supported_on_this_platform?
          defined?(Delayed::Job)
        end

        def poll
          stats.record_data_point locked_jobs
        end
      end
    end
  end
end
