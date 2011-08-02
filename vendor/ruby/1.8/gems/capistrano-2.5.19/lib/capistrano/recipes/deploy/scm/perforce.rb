require 'capistrano/recipes/deploy/scm/base'

# Notes: 
#  no global verbose flag for scm_verbose
#  sync, checkout and export are just sync in p4
#  
module Capistrano
  module Deploy
    module SCM

      # Implements the Capistrano SCM interface for the Perforce revision
      # control system (http://www.perforce.com).
      class Perforce < Base
        # Sets the default command name for this SCM. Users may override this
        # by setting the :scm_command variable.
        default_command "p4"

        # Perforce understands '#head' to refer to the latest revision in the
        # depot.
        def head
          'head'
        end

        # Returns the command that will sync the given revision to the given
        # destination directory. The perforce client has a fixed destination so
        # the files must be copied from there to their intended resting place.
        def checkout(revision, destination)
          p4_sync(revision, destination, p4sync_flags)
        end
        
        # Returns the command that will sync the given revision to the given
        # destination directory. The perforce client has a fixed destination so
        # the files must be copied from there to their intended resting place.
        def sync(revision, destination)
          p4_sync(revision, destination, p4sync_flags)
        end

        # Returns the command that will sync the given revision to the given
        # destination directory. The perforce client has a fixed destination so
        # the files must be copied from there to their intended resting place.
        def export(revision, destination)
          p4_sync(revision, destination, p4sync_flags)
        end
               
        # Returns the command that will do an "p4 diff2" for the two revisions.
        def diff(from, to=head)
          scm authentication, :diff2, "-u -db", "//#{p4client}/...#{rev_no(from)}", "//#{p4client}/...#{rev_no(to)}"
        end

        # Returns a "p4 changes" command for the two revisions.
        def log(from=1, to=head)
          scm authentication, :changes, "-s submitted", "//#{p4client}/...#{rev_no(from)},#{rev_no(to)}"
        end

        def query_revision(revision)
          return revision if revision.to_s =~ /^\d+$/
          command = scm(authentication, :changes, "-s submitted", "-m 1", "//#{p4client}/...#{rev_no(revision)}")
          yield(command)[/Change (\d+) on/, 1]
        end

        # Increments the given revision number and returns it.
        def next_revision(revision)
          revision.to_i + 1
        end

        # Determines what the response should be for a particular bit of text
        # from the SCM. Password prompts, connection requests, passphrases,
        # etc. are handled here.
        def handle_data(state, stream, text)
          case text
          when /\(P4PASSWD\) invalid or unset\./i
	          raise Capistrano::Error, "scm_password (or p4passwd) is incorrect or unset"
          when /Can.t create a new user.*/i
	          raise Capistrano::Error, "scm_username (or p4user) is incorrect or unset"
          when /Perforce client error\:/i	 
	          raise Capistrano::Error, "p4port is incorrect or unset"
          when /Client \'[\w\-\_\.]+\' unknown.*/i
	          raise Capistrano::Error, "p4client is incorrect or unset"
          end	             
        end

        private

          # Builds the set of authentication switches that perforce understands.
          def authentication
            [ p4port   && "-p #{p4port}",
              p4user   && "-u #{p4user}",
              p4passwd && "-P #{p4passwd}",
              p4client && "-c #{p4client}" ].compact.join(" ")
          end

          # Returns the command that will sync the given revision to the given
          # destination directory with specific options. The perforce client has 
          # a fixed destination so the files must be copied from there to their 
          # intended resting place.          
          def p4_sync(revision, destination, options="")
            scm authentication, :sync, options, "#{rev_no(revision)}", "&& cp -rf #{p4client_root} #{destination}"          
          end

          def p4client
            variable(:p4client)
          end

          def p4port
            variable(:p4port)
          end

          def p4user
            variable(:p4user) || variable(:scm_username)
          end
          
          def p4passwd
            variable(:p4passwd) || variable(:scm_password)
          end

          def p4sync_flags
            variable(:p4sync_flags) || "-f"
          end

          def p4client_root
            variable(:p4client_root) || "`#{command} #{authentication} client -o | grep ^Root | cut -f2`"
          end
          
          def rev_no(revision)                     
            case revision.to_s
            when "head"
              "#head"
            when /^\d+/  
              "@#{revision}"
            else
              revision
            end          
          end
      end

    end
  end
end
