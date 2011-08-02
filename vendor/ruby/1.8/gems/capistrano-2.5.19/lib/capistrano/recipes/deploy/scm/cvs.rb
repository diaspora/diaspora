require 'capistrano/recipes/deploy/scm/base'

module Capistrano
  module Deploy
    module SCM

      # Implements the Capistrano SCM interface for the CVS revision
      # control system.
      class Cvs < Base
        # Sets the default command name for this SCM. Users may override this
        # by setting the :scm_command variable.
        default_command "cvs"

        # CVS understands 'HEAD' to refer to the latest revision in the
        # repository.
        def head
          "HEAD"
        end

        # Returns the command that will check out the given revision to the
        # given destination.
        def checkout(revision, destination)
          [ prep_destination(destination),
            scm(verbose, cvs_root, :checkout, cvs_revision(revision), cvs_destination(destination), variable(:scm_module))
          ].join(' && ')
        end

        # Returns the command that will do an "cvs update" to the given
        # revision, for the working copy at the given destination.
        def sync(revision, destination)
          [ prep_destination(destination),
            scm(verbose, cvs_root, :update, cvs_revision(revision), cvs_destination(destination))
          ].join(' && ')
        end

        # Returns the command that will do an "cvs export" of the given revision
        # to the given destination.
        def export(revision, destination)
          [ prep_destination(destination),
            scm(verbose, cvs_root, :export, cvs_revision(revision), cvs_destination(destination), variable(:scm_module))
          ].join(' && ')
        end

        # Returns the command that will do an "cvs diff" for the two revisions.
        def diff(from, to=nil)
          rev_type = revision_type(from)
          if rev_type == :date
            range_args = "-D '#{from}' -D '#{to || 'now'}'"
          else
            range_args = "-r '#{from}' -r '#{to || head}'"
          end
          scm cvs_root, :diff, range_args
        end

        # Returns an "cvs log" command for the two revisions.
        def log(from, to=nil)
          rev_type = revision_type(from)
          if rev_type == :date
            range_arg = "-d '#{from}<#{to || 'now'}'"
          else
            range_arg = "-r '#{from}:#{to || head}'"
          end
          scm cvs_root, :log, range_arg
        end

        # Unfortunately, cvs doesn't support the concept of a revision number like 
        # subversion and other SCM's do.  For now, we'll rely on getting the timestamp
        # of the latest checkin under the revision that's passed to us.
        def query_revision(revision)
          return revision if revision_type(revision) == :date
          revision = yield(scm(cvs_root, :log, "-r#{revision}")).
                       grep(/^date:/).
                       map { |line| line[/^date: (.*?);/, 1] }.
                       sort.last + " UTC"
          return revision
        end

        # Determines what the response should be for a particular bit of text
        # from the SCM. Password prompts, connection requests, passphrases,
        # etc. are handled here.
        def handle_data(state, stream, text)
          logger.info "[#{stream}] #{text}"
          case text
          when /\bpassword.*:/i
            # prompting for a password
            "#{variable(:scm_password) || variable(:password)}\n"
          when %r{\(yes/no\)}
            # let's be agreeable...
            "yes\n"
          end
        end

        private

          # Constructs the CVSROOT command-line option
          def cvs_root
            root = ""
            root << "-d #{repository} " if repository
            root
          end
          
          # Constructs the destination dir command-line option
          def cvs_destination(destination)
            dest = ""
            if destination
              dest_parts = destination.split(/\//);
              dest << "-d #{dest_parts.pop}"
            end
            dest
          end
          
          # attempts to guess what type of revision we're working with
          def revision_type(rev)
            return :date if rev =~ /^\d{4}\/\d{2}\/\d{2} \d{2}:\d{2}:\d{2} UTC$/ # i.e 2007-05-15 08:13:25 UTC
            return :date if rev =~ /^\d{4}\/\d{2}\/\d{2} \d{2}:\d{2}:\d{2}$/ # i.e 2007-05-15 08:13:25
            return :revision if rev =~ /^\d/ # i.e. 1.2.1
            return :tag # i.e. RELEASE_1_2
          end
          
          # constructs the appropriate command-line switch for specifying a
          # "revision" in CVS.  This could be a tag, branch, revision (i.e. 1.3)
          # or a date (to be used with -d)
          def cvs_revision(rev)
            revision = ""
            revision << case revision_type(rev)
              when :date
                "-D \"#{rev}\"" if revision_type(rev) == :date
              when :revision
                "-r #{rev}"
              else
                "-r #{head}"
            end
            return revision
          end

          # If verbose output is requested, return nil, otherwise return the
          # command-line switch for "quiet" ("-Q").
          def verbose
            variable(:scm_verbose) ? nil : "-Q"
          end

          def prep_destination(destination)
            dest_parts = destination.split(/\//);
            checkout_dir = dest_parts.pop
            dest = dest_parts.join('/')
            "mkdir -p #{ dest } && cd #{ dest }"
          end
      end

    end
  end
end
