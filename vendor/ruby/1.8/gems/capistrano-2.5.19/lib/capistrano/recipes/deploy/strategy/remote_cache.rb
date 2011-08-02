require 'capistrano/recipes/deploy/strategy/remote'

module Capistrano
  module Deploy
    module Strategy

      # Implements the deployment strategy that keeps a cached checkout of
      # the source code on each remote server. Each deploy simply updates the
      # cached checkout, and then does a copy from the cached copy to the
      # final deployment location.
      class RemoteCache < Remote
        # Executes the SCM command for this strategy and writes the REVISION
        # mark file to each host.
        def deploy!
          update_repository_cache
          copy_repository_cache
        end

        def check!
          super.check do |d|
            d.remote.writable(shared_path)
          end
        end

        private

          def repository_cache
            File.join(shared_path, configuration[:repository_cache] || "cached-copy")
          end

          def update_repository_cache
            logger.trace "updating the cached checkout on all servers"
            command = "if [ -d #{repository_cache} ]; then " +
              "#{source.sync(revision, repository_cache)}; " +
              "else #{source.checkout(revision, repository_cache)}; fi"
            scm_run(command)
          end

          def copy_repository_cache
            logger.trace "copying the cached version to #{configuration[:release_path]}"
            if copy_exclude.empty? 
              run "cp -RPp #{repository_cache} #{configuration[:release_path]} && #{mark}"
            else
              exclusions = copy_exclude.map { |e| "--exclude=\"#{e}\"" }.join(' ')
              run "rsync -lrpt #{exclusions} #{repository_cache}/* #{configuration[:release_path]} && #{mark}"
            end
          end
          
          def copy_exclude
            @copy_exclude ||= Array(configuration.fetch(:copy_exclude, []))
          end
      end

    end
  end
end
