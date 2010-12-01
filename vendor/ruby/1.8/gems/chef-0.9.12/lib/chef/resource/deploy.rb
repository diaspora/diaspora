#
# Author:: Daniel DeLeo (<dan@kallistec.com>)
# Copyright:: Copyright (c) 2008 Opscode, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# EX:
# deploy "/my/deploy/dir" do
#   repo "git@github.com/whoami/project"
#   revision "abc123" # or "HEAD" or "TAG_for_1.0" or (subversion) "1234"
#   user "deploy_ninja"
#   enable_submodules true
#   migrate true
#   migration_command "rake db:migrate"
#   environment "RAILS_ENV" => "production", "OTHER_ENV" => "foo"
#   shallow_clone true
#   action :deploy # or :rollback
#   restart_command "touch tmp/restart.txt"
#   git_ssh_wrapper "wrap-ssh4git.sh"
#   scm_provider Chef::Provider::Git # is the default, for svn: Chef::Provider::Subversion
#   svn_username "whoami"
#   svn_password "supersecret"
# end

require "chef/resource/scm"

class Chef
  class Resource

    # Deploy: Deploy apps from a source control repository.
    #
    # Callbacks:
    # Callbacks can be a block or a string. If given a block, the code
    # is evaluated as an embedded recipe, and run at the specified
    # point in the deploy process. If given a string, the string is taken as
    # a path to a callback file/recipe. Paths are evaluated relative to the
    # release directory. Callback files can contain chef code (resources, etc.)
    #
    class Deploy < Chef::Resource

      provider_base Chef::Provider::Deploy
      
      def initialize(name, run_context=nil)
        super
        @resource_name = :deploy
        @deploy_to = name
        @environment = nil
        @repository_cache = 'cached-copy'
        @copy_exclude = []
        @purge_before_symlink = %w{log tmp/pids public/system}
        @create_dirs_before_symlink = %w{tmp public config}
        @symlink_before_migrate = {"config/database.yml" => "config/database.yml"}
        @symlinks = {"system" => "public/system", "pids" => "tmp/pids", "log" => "log"}
        @revision = 'HEAD'
        @action = :deploy
        @migrate = false
        @remote = "origin"
        @enable_submodules = false
        @shallow_clone = false
        @scm_provider = Chef::Provider::Git
        @svn_force_export = false
        @provider = Chef::Provider::Deploy::Timestamped
        @allowed_actions.push(:force_deploy, :deploy, :rollback)
      end

      # where the checked out/cloned code goes
      def destination
        @destination ||= shared_path + "/#{@repository_cache}"
      end

      # where shared stuff goes, i.e., logs, tmp, etc. goes here
      def shared_path
        @shared_path ||= @deploy_to + "/shared"
      end

      # where the deployed version of your code goes
      def current_path
        @current_path ||= @deploy_to + "/current"
      end

      def depth
        @shallow_clone ? "5" : nil
      end

      # note: deploy_to is your application "meta-root."
      def deploy_to(arg=nil)
        set_or_return(
          :deploy_to,
          arg,
          :kind_of => [ String ]
        )
      end

      def repo(arg=nil)
        set_or_return(
          :repo,
          arg,
          :kind_of => [ String ]
        )
      end
      alias :repository :repo

      def remote(arg=nil)
        set_or_return(
          :remote,
          arg,
          :kind_of => [ String ]
        )
      end

      def role(arg=nil)
        set_or_return(
          :role,
          arg,
          :kind_of => [ String ]
        )
      end

      def restart_command(arg=nil, &block)
        arg ||= block
        set_or_return(
          :restart_command,
          arg,
          :kind_of => [ String, Proc ]
        )
      end
      alias :restart :restart_command

      def migrate(arg=nil)
        set_or_return(
          :migrate,
          arg,
          :kind_of => [ TrueClass, FalseClass ]
        )
      end

      def migration_command(arg=nil)
        set_or_return(
          :migration_command,
          arg,
          :kind_of => [ String ]
        )
      end

      def user(arg=nil)
        set_or_return(
          :user,
          arg,
          :kind_of => [ String ]
        )
      end

      def group(arg=nil)
        set_or_return(
          :group,
          arg,
          :kind_of => [ String ]
        )
      end

      def enable_submodules(arg=nil)
        set_or_return(
          :enable_submodules,
          arg,
          :kind_of => [ TrueClass, FalseClass ]
        )
      end

      def shallow_clone(arg=nil)
        set_or_return(
          :shallow_clone,
          arg,
          :kind_of => [ TrueClass, FalseClass ]
        )
      end

      def repository_cache(arg=nil)
        set_or_return(
          :repository_cache,
          arg,
          :kind_of => [ String ]
        )
      end

      def copy_exclude(arg=nil)
        set_or_return(
          :copy_exclude,
          arg,
          :kind_of => [ String ]
        )
      end

      def revision(arg=nil)
        set_or_return(
          :revision,
          arg,
          :kind_of => [ String ]
        )
      end
      alias :branch :revision

      def git_ssh_wrapper(arg=nil)
        set_or_return(
          :git_ssh_wrapper,
          arg,
          :kind_of => [ String ]
        )
      end
      alias :ssh_wrapper :git_ssh_wrapper

      def svn_username(arg=nil)
        set_or_return(
          :svn_username,
          arg,
          :kind_of => [ String ]
        )
      end

      def svn_password(arg=nil)
        set_or_return(
          :svn_password,
          arg,
          :kind_of => [ String ]
        )
      end

      def svn_arguments(arg=nil)
        set_or_return(
          :svn_arguments,
          arg,
          :kind_of => [ String ]
        )
      end

      def svn_info_args(arg=nil)
        set_or_return(
          :svn_arguments,
          arg,
          :kind_of => [ String ])
      end

      def scm_provider(arg=nil)
        klass = if arg.kind_of?(String) || arg.kind_of?(Symbol)
                  lookup_provider_constant(arg)
                else
                  arg
                end
        set_or_return(
          :scm_provider,
          klass,
          :kind_of => [ Class ]
        )
      end

      def svn_force_export(arg=nil)
        set_or_return(
          :svn_force_export,
          arg,
          :kind_of => [ TrueClass, FalseClass ]
        )
      end

      def environment(arg=nil)
        if arg.is_a?(String)
          Chef::Log.info "Setting RAILS_ENV, RACK_ENV, and MERB_ENV to `#{arg}'"
          Chef::Log.warn "[DEPRECATED] please modify your deploy recipe or attributes to set the environment using a hash"
          arg = {"RAILS_ENV"=>arg,"MERB_ENV"=>arg,"RACK_ENV"=>arg}
        end
        set_or_return(
          :environment,
          arg,
          :kind_of => [ Hash ]
        )
      end

      # An array of paths, relative to your app's root, to be purged from a
      # SCM clone/checkout before symlinking. Use this to get rid of files and
      # directories you want to be shared between releases.
      # Default: ["log", "tmp/pids", "public/system"]
      def purge_before_symlink(arg=nil)
        set_or_return(
          :purge_before_symlink,
          arg,
          :kind_of => Array
        )
      end

      # An array of paths, relative to your app's root, where you expect dirs to
      # exist before symlinking. This runs after #purge_before_symlink, so you
      # can use this to recreate dirs that you had previously purged.
      # For example, if you plan to use a shared directory for pids, and you
      # want it to be located in $APP_ROOT/tmp/pids, you could purge tmp,
      # then specify tmp here so that the tmp directory will exist when you
      # symlink the pids directory in to the current release.
      # Default: ["tmp", "public", "config"]
      def create_dirs_before_symlink(arg=nil)
        set_or_return(
          :create_dirs_before_symlink,
          arg,
          :kind_of => Array
        )
      end

      # A Hash of shared/dir/path => release/dir/path. This attribute determines
      # which files and dirs in the shared directory get symlinked to the current
      # release directory, and where they go. If you have a directory
      # $shared/pids that you would like to symlink as $current_release/tmp/pids
      # you specify it as "pids" => "tmp/pids"
      # Default {"system" => "public/system", "pids" => "tmp/pids", "log" => "log"}
      def symlinks(arg=nil)
        set_or_return(
          :symlinks,
          arg,
          :kind_of => Hash
        )
      end

      # A Hash of shared/dir/path => release/dir/path. This attribute determines
      # which files in the shared directory get symlinked to the current release
      # directory and where they go. Unlike map_shared_files, these are symlinked
      # *before* any migration is run.
      # For a rails/merb app, this is used to link in a known good database.yml
      # (with the production db password) before running migrate.
      # Default {"config/database.yml" => "config/database.yml"}
      def symlink_before_migrate(arg=nil)
        set_or_return(
          :symlink_before_migrate,
          arg,
          :kind_of => Hash
        )
      end

      # Callback fires before migration is run.
      def before_migrate(arg=nil, &block)
        arg ||= block
        set_or_return(:before_migrate, arg, :kind_of => [Proc, String])
      end

      # Callback fires before symlinking
      def before_symlink(arg=nil, &block)
        arg ||= block
        set_or_return(:before_symlink, arg, :kind_of => [Proc, String])
      end

      # Callback fires before restart
      def before_restart(arg=nil, &block)
        arg ||= block
        set_or_return(:before_restart, arg, :kind_of => [Proc, String])
      end

      # Callback fires after restart
      def after_restart(arg=nil, &block)
        arg ||= block
        set_or_return(:after_restart, arg, :kind_of => [Proc, String])
      end

    end
  end
end
