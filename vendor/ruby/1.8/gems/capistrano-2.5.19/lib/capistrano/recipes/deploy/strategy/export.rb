require 'capistrano/recipes/deploy/strategy/remote'

module Capistrano
  module Deploy
    module Strategy

      # Implements the deployment strategy which does an SCM export on each
      # target host.
      class Export < Remote
        protected

          # Returns the SCM's export command for the revision to deploy.
          def command
            @command ||= source.export(revision, configuration[:release_path])
          end
      end

    end
  end
end
