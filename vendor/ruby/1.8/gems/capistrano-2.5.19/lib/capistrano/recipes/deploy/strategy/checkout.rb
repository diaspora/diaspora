require 'capistrano/recipes/deploy/strategy/remote'

module Capistrano
  module Deploy
    module Strategy

      # Implements the deployment strategy which does an SCM checkout on each
      # target host. This is the default deployment strategy for Capistrano.
      class Checkout < Remote
        protected

          # Returns the SCM's checkout command for the revision to deploy.
          def command
            @command ||= source.checkout(revision, configuration[:release_path])
          end
      end

    end
  end
end
