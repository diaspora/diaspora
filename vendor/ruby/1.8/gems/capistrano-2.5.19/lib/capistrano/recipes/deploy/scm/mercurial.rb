# Copyright 2007 Matthew Elder <sseses@gmail.com>
# based on work by Tobias Luetke

require 'capistrano/recipes/deploy/scm/base'

module Capistrano
  module Deploy
    module SCM

      # Implements the Capistrano SCM interface for the Mercurial revision
      # control system (http://www.selenic.com/mercurial/).
      # Latest updates at http://tackletechnology.org/oss/cap2-mercurial
      class Mercurial < Base
        # Sets the default command name for this SCM. Users may override this
        # by setting the :scm_command variable.
        default_command "hg"

        # For mercurial HEAD == tip except that it bases this assumption on what
        # tip is in the current repository (so push before you deploy)
        def head
          variable(:branch) || "tip"
        end

        # Clone the repository and update to the specified changeset.
        def checkout(changeset, destination)
          clone(destination) + " && " + update(changeset, destination)
        end

        # Pull from the repository and update to the specified changeset.
        def sync(changeset, destination)
          pull(destination) + " && " + update(changeset, destination)
        end

        # One day we will have hg archive, although i think its not needed
        def export(revision, destination)
          raise NotImplementedError, "`diff' is not implemented by #{self.class.name}" +
          "use checkout strategy"
        end

        # Compute the difference between the two changesets +from+ and +to+
        # as a unified diff.
        def diff(from, to=nil)
          scm :diff,
              "--rev #{from}",
              (to ? "--rev #{to}" : nil)
        end

        # Return a log of all changes between the two specified changesets,
        # +from+ and +to+, inclusive or the log for +from+ if +to+ is omitted.
        def log(from, to=nil)
          scm :log,
              verbose,
              "--rev #{from}" +
              (to ? ":#{to}" : "")
        end

        # Translates a tag to a changeset if needed or just returns changeset.
        def query_revision(changeset)
          cmd = scm :log,
                    verbose,
                    "-r #{changeset}",
                    "--template '{node|short}'"
                    yield cmd
        end

        # Determine response for SCM prompts
        # user/pass can come from ssh and http distribution methods
        # yes/no is for when ssh asks you about fingerprints
        def handle_data(state, stream, text)
          host = state[:channel][:host]
          logger.info "[#{host} :: #{stream}] #{text}"
          case text
          when /^user:/mi
            # support :scm_user for backwards compatibility of this module
            if user = variable(:scm_username) || variable(:scm_user)
              "#{user}\n"
            else
              raise "No variable :scm_username specified and Mercurial asked!\n" +
                "Prompt was: #{text}"
            end
          when /\bpassword:/mi
            unless pass = scm_password_or_prompt
              # fall back on old behavior of erroring out with msg
              raise "No variable :scm_password specified and Mercurial asked!\n" +
                "Prompt was: #{text}"
            end
            "#{pass}\n"
          when /yes\/no/i
            "yes\n"
          end
        end
        
        private

        # Fine grained mercurial commands
        def clone(destination) 
          scm :clone,
              verbose,
              "--noupdate", # do not update to tip when cloning is done
              repository,   # clone which repository?
              destination   # and put the clone where?
        end

        def pull(destination)
          scm :pull,
              verbose,
              "--repository #{destination}", # pull changes into what?
              repository                     # and pull the changes from?
        end

        def update(changeset, destination)
          scm :update,
              verbose,
              "--repository #{destination}", # update what?
              "--clean",                     # ignore untracked changes
              changeset                      # update to this changeset
        end

        # verbosity configuration grokking :)
        def verbose
          case variable(:scm_verbose)
            when nil   then nil
            when false then "--quiet"
            else            "--verbose"
          end
        end
        
        # honor Cap 2.1+'s :scm_prefer_prompt if present
        def scm_password_or_prompt
          @scm_password_or_prompt ||= variable(:scm_password) ||
            (Capistrano::CLI.password_prompt("hg password: ") if variable(:scm_prefer_prompt))
        end

      end
    end
  end
end
