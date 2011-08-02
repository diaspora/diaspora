require 'capistrano/recipes/deploy/scm/base'

module Capistrano
  module Deploy
    module SCM

      # A trivial SCM wrapper for representing the current working directory
      # as a repository. Obviously, not all operations are available for this
      # SCM, but it works sufficiently for use with the "copy" deployment
      # strategy.
      #
      # Use of this module is _not_ recommended; in general, it is good
      # practice to use some kind of source code management even for anything
      # you are wanting to deploy. However, this module is provided in
      # acknowledgement of the cases where trivial deployment of your current
      # working directory is desired.
      #
      #   set :repository, "."
      #   set :scm, :none
      #   set :deploy_via, :copy
      class None < Base
        # No versioning, thus, no head. Returns the empty string.
        def head
          ""
        end

        # Simply does a copy from the :repository directory to the
        # :destination directory.
        def checkout(revision, destination)
          !Capistrano::Deploy::LocalDependency.on_windows? ? "cp -R #{repository} #{destination}" : "xcopy #{repository} \"#{destination}\" /S/I/Y/Q/E"
        end

        alias_method :export, :checkout

        # No versioning, so this just returns the argument, with no
        # modification.
        def query_revision(revision)
          revision
        end
      end

    end
  end
end
