DependencyDetection.defer do
  depends_on do
    defined?(PhusionPassenger)
  end

  executes do
    NewRelic::Agent.logger.debug "Installing Passenger event hooks."

    PhusionPassenger.on_event(:stopping_worker_process) do
      NewRelic::Agent.logger.debug "Passenger stopping this process, shutdown the agent."
      NewRelic::Agent.instance.shutdown
    end

    PhusionPassenger.on_event(:starting_worker_process) do |forked|
      # We want to reset the stats from the stats engine in case any carried
      # over into the spawned process.  Don't clear them in case any were
      # cached.  We do this even in conservative spawning.
      NewRelic::Agent.after_fork(:force_reconnect => true)
    end
  end
end

DependencyDetection.defer do
  depends_on do
    defined?(::Passenger) && defined?(::Passenger::AbstractServer) || defined?(::IN_PHUSION_PASSENGER)
  end

  executes do
    # We're on an older version of passenger
    NewRelic::Agent.logger.warn "An older version of Phusion Passenger has been detected.  We recommend using at least release 2.1.1."

    NewRelic::Agent::Instrumentation::MetricFrame.check_server_connection = true
  end
end
