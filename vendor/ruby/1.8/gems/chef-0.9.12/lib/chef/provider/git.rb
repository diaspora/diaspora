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


require 'chef/log'
require 'chef/provider'
require 'chef/mixin/command'
require 'fileutils'

class Chef
  class Provider
    class Git < Chef::Provider
      
      include Chef::Mixin::Command
      
      def load_current_resource
        @current_resource = Chef::Resource::Git.new(@new_resource.name)
        if current_revision = find_current_revision
          @current_resource.revision current_revision
        end
      end
      
      def action_checkout
        if !::File.exist?(@new_resource.destination) || Dir.entries(@new_resource.destination) == ['.','..']
          clone
          checkout
          enable_submodules
          @new_resource.updated_by_last_action(true)
        else
          Chef::Log.info "Taking no action, checkout destination #{@new_resource.destination} already exists or is a non-empty directory"
        end
      end
      
      def action_export
        action_checkout
        FileUtils.rm_rf(::File.join(@new_resource.destination,".git"))
        @new_resource.updated_by_last_action(true)
      end
      
      def action_sync
        if !::File.exist?(@new_resource.destination) || Dir.entries(@new_resource.destination) == ['.','..']
          action_checkout
          @new_resource.updated_by_last_action(true)
        else
          current_rev = find_current_revision
          Chef::Log.debug "#{@new_resource} revision: #{current_rev}"
          sync
          enable_submodules
          new_rev = find_current_revision
          if current_rev == new_rev
            @new_resource.updated_by_last_action(false)
          else
            Chef::Log.info "#{@new_resource} updated revision is: #{new_rev}"
            @new_resource.updated_by_last_action(true)
          end
        end
      end
      
      def find_current_revision
        if ::File.exist?(::File.join(cwd, ".git"))
          status, result, error_message = output_of_command("git rev-parse HEAD", run_options(:cwd=>cwd))
          
          # 128 is returned when we're not in a git repo. this is fine
          unless [0,128].include?(status.exitstatus)
            handle_command_failures(status, "STDOUT: #{result}\nSTDERR: #{error_message}")
          end
        end
        sha_hash?(result) ? result : nil
      end
      
      def clone
        remote = @new_resource.remote

        args = []
        args << "-o #{remote}" unless remote == 'origin'
        args << "--depth #{@new_resource.depth}" if @new_resource.depth
        
        Chef::Log.info "Cloning repo #{@new_resource.repository} to #{@new_resource.destination}"
        
        clone_cmd = "#{git} clone #{args.join(' ')} #{@new_resource.repository} #{@new_resource.destination}"
        run_command(run_options(:command => clone_cmd))
      end
      
      def checkout
        sha_ref = revision_sha
        Chef::Log.info "Checking out branch: #{@new_resource.revision} reference: #{sha_ref}"
        # checkout into a local branch rather than a detached HEAD
        run_command(run_options(:command => "#{git} checkout -b deploy #{sha_ref}", :cwd => @new_resource.destination))
      end
      
      def enable_submodules
        if @new_resource.enable_submodules
          Chef::Log.info "Enabling git submodules"
          command = "#{git} submodule init && #{git} submodule update"
          run_command(run_options(:command => command, :cwd => @new_resource.destination))
        end
      end
      
      def sync
        revision = revision_sha
        sync_command = []

        # Use git-config to setup a remote tracking branches. Could use
        # git-remote but it complains when a remote of the same name already
        # exists, git-config will just silenty overwrite the setting every
        # time. This could cause wierd-ness in the remote cache if the url
        # changes between calls, but as long as the repositories are all
        # based from each other it should still work fine.
        if @new_resource.remote != 'origin'
          Chef::Log.info  "Configuring remote tracking branches for repository #{@new_resource.repository} "+
                          "at remote #{@new_resource.remote}"
          sync_command << "#{git} config remote.#{@new_resource.remote}.url #{@new_resource.repository}"
          sync_command << "#{git} config remote.#{@new_resource.remote}.fetch +refs/heads/*:refs/remotes/#{@new_resource.remote}/*"
        end

        # since we're in a local branch already, just reset to specified revision rather than merge
        sync_command << "#{git} fetch #{@new_resource.remote} && #{git} fetch #{@new_resource.remote} --tags && #{git} reset --hard #{revision}"
        Chef::Log.info "Fetching updates from #{new_resource.remote} and resetting to revison #{revision}"
        run_command(run_options(:command => sync_command.join(" && "), :cwd => @new_resource.destination))
      end
      
      def revision_sha
        @revision_sha ||= begin
          assert_revision_not_remote
          
          if sha_hash?(@new_resource.revision)
            @revision_sha = @new_resource.revision 
          else
            resolved_reference = remote_resolve_reference
            @revision_sha = extract_revision(resolved_reference)
          end
        end
      end
      
      alias :revision_slug :revision_sha
      
      def remote_resolve_reference
        command = scm('ls-remote', @new_resource.repository, @new_resource.revision)
        Chef::Log.debug("Executing #{command}")
        begin
          status, result, error_message = output_of_command(command, run_options)
          handle_command_failures(status, "STDOUT: #{result}\nSTDERR: #{error_message}")
        rescue RuntimeError => e
          raise RuntimeError, e.message + "\n" + "Could not access the remote Git repository. "+
                "If this is a private repository, please verify that the deploy key for your application " +
                "has been added to your remote Git account."
        end
        result
      end
      
      private
      
      def run_options(run_opts={})
        run_opts[:user] = @new_resource.user if @new_resource.user
        run_opts[:group] = @new_resource.group if @new_resource.group
        run_opts[:environment] = {"GIT_SSH" => @new_resource.ssh_wrapper} if @new_resource.ssh_wrapper
        run_opts
      end
      
      def cwd
        @new_resource.destination
      end
      
      def scm(*args)
        [git, *args].compact.join(" ")
      end

      def git
        'git'
      end
      
      def sha_hash?(string)
        string =~ /^[0-9a-f]{40}$/
      end
      
      def assert_revision_not_remote
        if @new_resource.revision =~ /^origin\//
          reference = @new_resource.revision
          error_text =  "Deploying remote branches is not supported. " +
                        "Specify the remote branch as a local branch for " +
                        "the git repository you're deploying from " + 
                        "(ie: '#{reference.gsub('origin/', '')}' rather than '#{reference}')."
          raise RuntimeError, error_text
        end
      end
      
      def extract_revision(resolved_reference)
        unless resolved_reference =~ /^([0-9a-f]{40})\s+(\S+)/
          raise "Unable to resolve reference for '#{resolved_reference}' on repository '#{@new_resource.repository}'."
        end
        $1
      end
      
    end
  end
end
