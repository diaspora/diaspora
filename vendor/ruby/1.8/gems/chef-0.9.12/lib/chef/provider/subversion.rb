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
    class Subversion < Chef::Provider
      
      include Chef::Mixin::Command
      
      def load_current_resource
        @current_resource = Chef::Resource::Subversion.new(@new_resource.name)

        unless [:export, :force_export].include?(@new_resource.action.first)
          if current_revision = find_current_revision
            @current_resource.revision current_revision
          end
        end
      end
      
      def action_checkout
        run_command(run_options(:command => checkout_command))
        @new_resource.updated_by_last_action(true)
      end
      
      def action_export
        run_command(run_options(:command => export_command))
        @new_resource.updated_by_last_action(true)
      end
      
      def action_force_export
        run_command(run_options(:command => export_command))
        @new_resource.updated_by_last_action(true)
      end
      
      def action_sync
        if !::File.exist?(@new_resource.destination + "/.svn") || ::Dir.entries(@new_resource.destination) == ['.','..']
          action_checkout
        else
          run_command(run_options(:command => sync_command))
        end
        @new_resource.updated_by_last_action(true)
      end
      
      def sync_command
        Chef::Log.info "Updating working copy #{@new_resource.destination} to revision #{@new_resource.revision}"
        scm :update, @new_resource.svn_arguments, verbose, authentication, "-r#{revision_int}", @new_resource.destination
      end
      
      def checkout_command
        Chef::Log.info "checking out #{@new_resource.repository} at revision #{@new_resource.revision} to #{@new_resource.destination}"
        scm :checkout, @new_resource.svn_arguments, verbose, authentication, 
            "-r#{revision_int}", @new_resource.repository, @new_resource.destination
      end
      
      def export_command
        Chef::Log.info "exporting #{@new_resource.repository} at revision #{@new_resource.revision} to #{@new_resource.destination}"
        args = ["--force"]
        args << @new_resource.svn_arguments << verbose << authentication <<
            "-r#{revision_int}" << @new_resource.repository << @new_resource.destination
        scm :export, *args
      end
      
      # If the specified revision isn't an integer ("HEAD" for example), look
      # up the revision id by asking the server
      # If the specified revision is an integer, trust it.
      def revision_int
        @revision_int ||= begin
          if @new_resource.revision =~ /^\d+$/
            @new_resource.revision
          else
            command = scm(:info, @new_resource.repository, @new_resource.svn_info_args, authentication, "-r#{@new_resource.revision}")
            status, svn_info, error_message = output_of_command(command, run_options)
            handle_command_failures(status, "STDOUT: #{svn_info}\nSTDERR: #{error_message}")
            extract_revision_info(svn_info)
          end
        end
      end
      
      alias :revision_slug :revision_int
      
      def find_current_revision
        return nil unless ::File.exist?(@new_resource.destination)
        command = scm(:info)
        status, svn_info, error_message = output_of_command(command, run_options(:cwd => cwd))
        
        unless [0,1].include?(status.exitstatus)
          handle_command_failures(status, "STDOUT: #{svn_info}\nSTDERR: #{error_message}")
        end
        extract_revision_info(svn_info)
      end
      
      def run_options(run_opts={})
        run_opts[:user] = @new_resource.user if @new_resource.user
        run_opts[:group] = @new_resource.group if @new_resource.group
        run_opts
      end
      
      private
      
      def cwd
        @new_resource.destination
      end
      
      def verbose
        "-q"
      end
      
      def extract_revision_info(svn_info)
        begin
          repo_attrs = YAML.load(svn_info)
        rescue ArgumentError
          # YAML doesn't appreciate input like "svn: '/tmp/deploydir' is not a working copy\n"
          return nil
        end
        raise "Could not parse `svn info` data: #{svn_info}" unless repo_attrs.kind_of?(Hash)
        rev = (repo_attrs['Last Changed Rev'] || repo_attrs['Revision']).to_s
        Chef::Log.debug "Resolved revision #{@new_resource.revision} to #{rev}"
        rev
      end
      
      # If a username is configured for the SCM, return the command-line
      # switches for that. Note that we don't need to return the password
      # switch, since Capistrano will check for that prompt in the output
      # and will respond appropriately.
      def authentication
        return "" unless @new_resource.svn_username
        result = "--username #{@new_resource.svn_username} "
        result << "--password #{@new_resource.svn_password} "
        result
      end
      
      def scm(*args)
        ['svn', *args].compact.join(" ")
      end

    end
  end
end
