require 'capistrano/recipes/deploy/scm/base'

module Capistrano
  module Deploy
    module SCM

      # An SCM module for using Git as your source control tool with Capistrano
      # 2.0.  If you are using Capistrano 1.x, use this plugin instead:
      #
      #   http://scie.nti.st/2007/3/16/capistrano-with-git-shared-repository
      #
      # Assumes you are using a shared Git repository.
      #
      # Parts of this plugin borrowed from Scott Chacon's version, which I
      # found on the Capistrano mailing list but failed to be able to get
      # working.
      #
      # FEATURES:
      #
      #   * Very simple, only requiring 2 lines in your deploy.rb.
      #   * Can deploy different branches, tags, or any SHA1 easily.
      #   * Supports prompting for password / passphrase upon checkout.
      #     (I am amazed at how some plugins don't do this)
      #   * Supports :scm_command, :scm_password, :scm_passphrase Capistrano
      #     directives.
      #
      # CONFIGURATION
      # -------------
      #
      # Use this plugin by adding the following line in your config/deploy.rb:
      #
      #   set :scm, :git
      #
      # Set <tt>:repository</tt> to the path of your Git repo:
      #
      #   set :repository, "someuser@somehost:/home/myproject"
      #
      # The above two options are required to be set, the ones below are
      # optional.
      #
      # You may set <tt>:branch</tt>, which is the reference to the branch, tag,
      # or any SHA1 you are deploying, for example:
      #
      #   set :branch, "master"
      #
      # Otherwise, HEAD is assumed.  I strongly suggest you set this.  HEAD is
      # not always the best assumption.
      #
      # You may also set <tt>:remote</tt>, which will be used as a name for remote
      # tracking of repositories. This option is intended for use with the
      # <tt>:remote_cache</tt> strategy in a distributed git environment.
      #
      # For example in the projects <tt>config/deploy.rb</tt>:
      #
      #   set :repository, "#{scm_user}@somehost:~/projects/project.git"
      #   set :remote, "#{scm_user}"
      #
      # Then each person with deploy priveledges can add the following to their
      # local <tt>~/.caprc</tt> file:
      #
      #   set :scm_user, 'someuser'
      #
      # Now any time a person deploys the project, their repository will be
      # setup as a remote git repository within the cached repository.
      #
      # The <tt>:scm_command</tt> configuration variable, if specified, will
      # be used as the full path to the git executable on the *remote* machine:
      #
      #   set :scm_command, "/opt/local/bin/git"
      #
      # For compatibility with deploy scripts that may have used the 1.x
      # version of this plugin before upgrading, <tt>:git</tt> is still
      # recognized as an alias for :scm_command.
      #
      # Set <tt>:scm_password</tt> to the password needed to clone your repo
      # if you don't have password-less (public key) entry:
      #
      #   set :scm_password, "my_secret'
      #
      # Otherwise, you will be prompted for a password.
      #
      # <tt>:scm_passphrase</tt> is also supported.
      #
      # The remote cache strategy is also supported.
      #
      #   set :repository_cache, "git_master"
      #   set :deploy_via, :remote_cache
      #
      # For faster clone, you can also use shallow cloning.  This will set the
      # '--depth' flag using the depth specified.  This *cannot* be used
      # together with the :remote_cache strategy
      #
      #   set :git_shallow_clone, 1
      #
      # For those that don't like to leave your entire repository on
      # your production server you can:
      #
      #   set :deploy_via, :export
      #
      # To deploy from a local repository:
      #
      #   set :repository, "file://."
      #   set :deploy_via, :copy
      #
      # AUTHORS
      # -------
      #
      # Garry Dolley http://scie.nti.st
      # Contributions by Geoffrey Grosenbach http://topfunky.com
      #              Scott Chacon http://jointheconversation.org
      #                          Alex Arnell http://twologic.com
      #                                   and Phillip Goldenburg

      class Git < Base
        # Sets the default command name for this SCM on your *local* machine.
        # Users may override this by setting the :scm_command variable.
        default_command "git"

        # When referencing "head", use the branch we want to deploy or, by
        # default, Git's reference of HEAD (the latest changeset in the default
        # branch, usually called "master").
        def head
          variable(:branch) || 'HEAD'
        end

        def origin
          variable(:remote) || 'origin'
        end

        # Performs a clone on the remote machine, then checkout on the branch
        # you want to deploy.
        def checkout(revision, destination)
          git    = command
          remote = origin

          args = []
          args << "-o #{remote}" unless remote == 'origin'
          if depth = variable(:git_shallow_clone)
            args << "--depth #{depth}"
          end

          execute = []
          if args.empty?
            execute << "#{git} clone #{verbose} #{variable(:repository)} #{destination}"
          else
            execute << "#{git} clone #{verbose} #{args.join(' ')} #{variable(:repository)} #{destination}"
          end

          # checkout into a local branch rather than a detached HEAD
          execute << "cd #{destination} && #{git} checkout #{verbose} -b deploy #{revision}"
          
          if variable(:git_enable_submodules)
            execute << "#{git} submodule #{verbose} init"
            execute << "#{git} submodule #{verbose} sync"
            execute << "#{git} submodule #{verbose} update"
          end

          execute.join(" && ")
        end
        
        # An expensive export. Performs a checkout as above, then
        # removes the repo.
        def export(revision, destination)
          checkout(revision, destination) << " && rm -Rf #{destination}/.git"
        end

        # Merges the changes to 'head' since the last fetch, for remote_cache
        # deployment strategy
        def sync(revision, destination)
          git     = command
          remote  = origin

          execute = []
          execute << "cd #{destination}"

          # Use git-config to setup a remote tracking branches. Could use
          # git-remote but it complains when a remote of the same name already
          # exists, git-config will just silenty overwrite the setting every
          # time. This could cause wierd-ness in the remote cache if the url
          # changes between calls, but as long as the repositories are all
          # based from each other it should still work fine.
          if remote != 'origin'
            execute << "#{git} config remote.#{remote}.url #{variable(:repository)}"
            execute << "#{git} config remote.#{remote}.fetch +refs/heads/*:refs/remotes/#{remote}/*"
          end

          # since we're in a local branch already, just reset to specified revision rather than merge
          execute << "#{git} fetch #{verbose} #{remote} && #{git} reset #{verbose} --hard #{revision}"

          if variable(:git_enable_submodules)
            execute << "#{git} submodule #{verbose} init"
            execute << "for mod in `#{git} submodule status | awk '{ print $2 }'`; do #{git} config -f .git/config submodule.${mod}.url `#{git} config -f .gitmodules --get submodule.${mod}.url` && echo Synced $mod; done"
            execute << "#{git} submodule #{verbose} sync"
            execute << "#{git} submodule #{verbose} update"
          end

          # Make sure there's nothing else lying around in the repository (for
          # example, a submodule that has subsequently been removed).
          execute << "#{git} clean #{verbose} -d -x -f"

          execute.join(" && ")
        end

        # Returns a string of diffs between two revisions
        def diff(from, to=nil)
          from << "..#{to}" if to
          scm :diff, from
        end

        # Returns a log of changes between the two revisions (inclusive).
        def log(from, to=nil)
          scm :log, "#{from}..#{to}"
        end

        # Getting the actual commit id, in case we were passed a tag
        # or partial sha or something - it will return the sha if you pass a sha, too
        def query_revision(revision)
          raise ArgumentError, "Deploying remote branches is no longer supported.  Specify the remote branch as a local branch for the git repository you're deploying from (ie: '#{revision.gsub('origin/', '')}' rather than '#{revision}')." if revision =~ /^origin\//
          return revision if revision =~ /^[0-9a-f]{40}$/
          command = scm('ls-remote', repository, revision)
          result = yield(command)
          revdata = result.split(/[\t\n]/)
          newrev = nil
          revdata.each_slice(2) do |refs|
            rev, ref = *refs
            if ref.sub(/refs\/.*?\//, '').strip == revision.to_s
              newrev = rev
              break
            end
          end
          raise "Unable to resolve revision for '#{revision}' on repository '#{repository}'." unless newrev =~ /^[0-9a-f]{40}$/
          return newrev
        end

        def command
          # For backwards compatibility with 1.x version of this module
          variable(:git) || super
        end

        # Determines what the response should be for a particular bit of text
        # from the SCM. Password prompts, connection requests, passphrases,
        # etc. are handled here.
        def handle_data(state, stream, text)
          host = state[:channel][:host]
          logger.info "[#{host} :: #{stream}] #{text}"
          case text
          when /\bpassword.*:/i
            # git is prompting for a password
            unless pass = variable(:scm_password)
              pass = Capistrano::CLI.password_prompt
            end
            "#{pass}\n"
          when %r{\(yes/no\)}
            # git is asking whether or not to connect
            "yes\n"
          when /passphrase/i
            # git is asking for the passphrase for the user's key
            unless pass = variable(:scm_passphrase)
              pass = Capistrano::CLI.password_prompt
            end
            "#{pass}\n"
          when /accept \(t\)emporarily/
            # git is asking whether to accept the certificate
            "t\n"
          end
        end

        private

          # If verbose output is requested, return nil, otherwise return the
          # command-line switch for "quiet" ("-q").
          def verbose
            variable(:scm_verbose) ? nil : "-q"
          end
      end
    end
  end
end
