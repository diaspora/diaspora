#
# Author:: Nuo Yan <nuo@opscode.com>
# Copyright:: Copyright (c) 2010 Opscode, Inc
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

require 'chef/provider/service/init'

class Chef::Provider::Service::Windows < Chef::Provider::Service::Init

  def initialize(new_resource, run_context)
    super
    @init_command = "sc"
  end

  def load_current_resource
    @current_resource = Chef::Resource::Service.new(@new_resource.name)
    @current_resource.service_name(@new_resource.service_name)
    status = IO.popen("#{@init_command} query #{@new_resource.service_name}").entries
    raise Chef::Exceptions::Exec, "Service #{@new_resource.service_name} does not exist.\n#{status.join}\n" if status[0].include?("FAILED 1060")

    begin
      started = status[3].include?("4")
      @current_resource.running started

      start_type = IO.popen("#{@init_command} qc #{@new_resource.service_name}").entries[4]
      @current_resource.enabled(start_type.include?('2') || start_type.include?('3') ? true : false)

      Chef::Log.debug "#{@new_resource}: running: #{@current_resource.running}"
    rescue StandardError
      raise Chef::Exceptions::Exec
    rescue Chef::Exceptions::Exec
      Chef::Log.debug "Failed to determine the current status of the service, assuming it is not running"
      @current_resource.running false
      nil
    end
    @current_resource
  end

  def start_service
    begin
      result = if @new_resource.start_command
                 Chef::Log.debug "starting service using the given start_command"
                 IO.popen(@new_resource.start_command).readlines
               else
                 IO.popen("#{@init_command} start #{@new_resource.service_name}").readlines
               end
      Chef::Log.debug result.join
      result[3].include?('4') || result.include?('2') ? true : false
    rescue
      Chef::Log.debug "Failed to start service #{@new_resource.service_name}"
      false
    end
  end

  def stop_service
    begin
      Chef::Log.debug "stopping service using the given stop_command"
      result = if @new_resource.stop_command
                 IO.popen(@new_resource.stop_command).readlines
               else
                 IO.popen("#{@init_command} stop #{@new_resource.service_name}").readlines
               end
      Chef::Log.debug result.join
      result[3].include?('1')
    rescue
      Chef::Log.debug "Failed to stop service #{@new_resource.service_name}"
      false
    end
  end

  def restart_service
    begin
      if @new_resource.restart_command
        Chef::Log.debug "restarting service using the given restart_command"
        result = IO.popen(@new_resource.restart_command).readlines
        Chef::Log.debug result.join
      else
        Chef::Log.debug IO.popen("#{@init_command} stop #{@new_resource.service_name}").readlines.join
        sleep 1
        result = IO.popen("#{@init_command} start #{@new_resource.service_name}").readlines
        Chef::Log.debug result.join
      end
      result[3].include?('4') || result.include?('2')
    rescue
      Chef::Log.debug "Failed to restart service #{@new_resource.service_name}"
      false
    end
  end

  def enable_service()
    begin
      Chef::Log.debug result = IO.popen("#{@init_command} config #{@new_resource.service_name} start= #{determine_startup_type}").readlines.join
      result.include?('SUCCESS')
    rescue
      Chef::Log.debug "Failed to enable service #{@new_resource.service_name}"
      false
    end
  end

  def disable_service()
    begin
      Chef::Log.debug result = IO.popen("#{@init_command} config #{@new_resource.service_name} start= disabled").readlines.join
      result.include?('SUCCESS')
    rescue
      Chef::Log.debug "Failed to disable service #{@new_resource.service_name}"
      false
    end
  end

  private

  def determine_startup_type
    {:automatic => 'auto', :mannual => 'demand'}[@new_resource.startup_type]
  end

end