require 'capistrano/recipes/deploy/scm/base'

module Capistrano
  module Deploy
    module SCM

      # Implements the Capistrano SCM interface for the darcs revision
      # control system (http://www.abridgegame.org/darcs/).
      class Darcs < Base
        # Sets the default command name for this SCM. Users may override this
        # by setting the :scm_command variable.
        default_command "darcs"

        # Because darcs does not have any support for pseudo-ids, we'll just
        # return something here that we can use in the helpers below for
        # determining whether we need to look up the latest revision.
        def head
          :head
        end

        def to_match(revision)
          if revision.nil? || revision == self.head
            nil
          else
            "--to-match='hash #{revision}'"
          end
        end
        
        # Returns the command that will check out the given revision to the
        # given destination. The 'revision' parameter must be the 'hash' value
        # for the revision in question, as given by 'darcs changes --xml-output'.
        def checkout(revision, destination)
          scm :get, *[verbose, 
                      "--repo-name=#{destination}", 
                      to_match(revision),
                      repository].compact
        end

        # Tries to update the destination repository in-place, to bring it up
        # to the given revision. Note that because darcs' "pull" operation
        # does not support a "to-match" argument (or similar), this basically
        # nukes the destination directory and re-gets it.
        def sync(revision, destination)
          ["rm -rf #{destination}", checkout(revision, destination)].join(" && ")
        end

        # Darcs does not have a real 'export' option; there is 'darcs dist',
        # but that presupposes a utility that can untar and ungzip the dist
        # file. We'll cheat and just do a get, followed by a deletion of the
        # _darcs metadata directory.
        def export(revision, destination)
          [checkout(revision, destination), "rm -rf #{destination}/_darcs"].join(" && ")
        end

        # Returns the command that will do a "darcs diff" for the two revisions.
        # Each revision must be the 'hash' identifier of a darcs revision.
        def diff(from, to=nil)
          scm :diff, "--from-match 'hash #{from}'", to && "--to-match 'hash #{to}'"
        end

        # Returns the log of changes between the two revisions. Each revision
        # must be the 'hash' identifier of a darcs revision.
        def log(from, to=nil)
          scm :changes, "--from-match 'hash #{from}'", to && "--to-match 'hash #{to}'", "--repo=#{repository}"
        end

        # Attempts to translate the given revision identifier to a "real"
        # revision. If the identifier is a symbol, it is assumed to be a
        # pseudo-id. Otherwise, it will be immediately returned. If it is a
        # pseudo-id, a set of commands to execute will be yielded, and the
        # result of executing those commands must be returned by the block.
        # This method will then extract the actual revision hash from the
        # returned data.
        def query_revision(revision)
          case revision
          when :head
            xml = yield(scm(:changes, "--last 1", "--xml-output", "--repo=#{repository}"))
            return xml[/hash='(.*?)'/, 1]
          else return revision
          end
        end

        private

          def verbose
            case variable(:scm_verbose)
            when nil then "-q"
            when false then nil
            else "-v"
            end
          end
      end

    end
  end
end
