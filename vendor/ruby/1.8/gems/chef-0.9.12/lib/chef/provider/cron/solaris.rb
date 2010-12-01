#
# Author:: Bryan McLellan (btm@loftninjas.org)
# Author:: Toomas Pelberg (toomasp@gmx.net)
# Copyright:: Copyright (c) 2009 Bryan McLellan
# Copyright:: Copyright (c) 2010 Toomas Pelberg
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
require 'chef/mixin/command'
require 'chef/provider'

class Chef
  class Provider
    class Cron
      class Solaris < Chef::Provider::Cron
      include Chef::Mixin::Command

      CRON_PATTERN = /([-0-9*,\/]+)\s([-0-9*,\/]+)\s([-0-9*,\/]+)\s([-0-9*,\/]+)\s([-0-9*,\/]+)\s(.*)/

      def initialize(new_resource, run_context)
        super(new_resource, run_context)
        @cron_exists = false
        @cron_empty = false
      end
      attr_accessor :cron_exists, :cron_empty

      def load_current_resource
        crontab_lines = []
        @current_resource = Chef::Resource::Cron.new(@new_resource.name)
        @current_resource.user(@new_resource.user)
        status = popen4("crontab -l #{@new_resource.user}") do |pid, stdin, stdout, stderr|
          stdout.each_line { |line| crontab_lines << line }
        end
        if status.exitstatus > 1
          raise Chef::Exceptions::Cron, "Error determining state of #{@new_resource.name}, exit: #{status.exitstatus}"
        elsif status.exitstatus == 0
          cron_found = false
          crontab_lines.each do |line|
            case line.chomp
            when "# Chef Name: #{@new_resource.name}"
              Chef::Log.debug("Found cron '#{@new_resource.name}'")
              cron_found = true
              @cron_exists = true
              next
            when /^MAILTO=(\S*)/
              @current_resource.mailto($1) if cron_found
              next
            when /^PATH=(\S*)/
              @current_resource.path($1) if cron_found
              next
            when /^SHELL=(\S*)/
              @current_resource.shell($1) if cron_found
              next
            when /^HOME=(\S*)/
              @current_resource.home($1) if cron_found
              next
            when CRON_PATTERN
              if cron_found
                @current_resource.minute($1)
                @current_resource.hour($2)
                @current_resource.day($3)
                @current_resource.month($4)
                @current_resource.weekday($5)
                @current_resource.command($6)
                cron_found=false
              end
              next
            else
              next
            end
          end
          Chef::Log.debug("Cron '#{@new_resource.name}' not found") unless @cron_exists
        elsif status.exitstatus == 1
          Chef::Log.debug("Cron empty for '#{@new_resource.user}'")
          @cron_empty = true
        end

        @current_resource
      end

      def compare_cron
        [ :minute, :hour, :day, :month, :weekday, :command, :mailto, :path, :shell, :home ].any? do |cron_var|
          !@new_resource.send(cron_var).nil? && @new_resource.send(cron_var) != @current_resource.send(cron_var)
        end
      end

      def write_crontab(crontab)
        tempcron = Tempfile.new("chef-cron")
        tempcron << crontab
        tempcron.flush
        tempcron.chmod(0644)
        status = run_command(:command => "/usr/bin/crontab #{tempcron.path}",:user => @new_resource.user)
        if(status == 0)
          @new_resource.updated_by_last_action(true)
        else
          @new_resource.updated_by_last_action(false)
        end
        tempcron.close!
        return status
      end

      def action_create
        crontab = String.new
        newcron = String.new
        cron_found = false

        newcron << "# Chef Name: #{new_resource.name}\n"
        [ :mailto, :path, :shell, :home ].each do |v|
          newcron << "#{v.to_s.upcase}=#{@new_resource.send(v)}\n" if @new_resource.send(v)
        end
        newcron << "#{@new_resource.minute} #{@new_resource.hour} #{@new_resource.day} #{@new_resource.month} #{@new_resource.weekday} #{@new_resource.command}\n"

        if @cron_exists
          unless compare_cron
            Chef::Log.debug("Skipping existing cron entry '#{@new_resource.name}'")
            return
          end
          status = popen4("crontab -l #{@new_resource.user}") do |pid, stdin, stdout, stderr|
            stdout.each_line do |line|
              case line.chomp
              when "# Chef Name: #{@new_resource.name}"
                cron_found = true
                next
              when CRON_PATTERN
                if cron_found
                  cron_found = false
                  crontab << newcron
                  next
                end
              else
                next if cron_found
              end
              crontab << line
            end
          end

          status = write_crontab(crontab)
          Chef::Log.info("Updated cron '#{@new_resource.name}'")
        else
          unless @cron_empty
            status = popen4("crontab -l #{@new_resource.user}") do |pid, stdin, stdout, stderr|
              stdout.each { |line| crontab << line }
            end
          end

          crontab << newcron
          status = write_crontab(crontab)
          Chef::Log.info("Added cron '#{@new_resource.name}'")
        end
      end

      def action_delete
        if @cron_exists
          crontab = String.new
          cron_found = false
          status = popen4("crontab -l #{@new_resource.user}") do |pid, stdin, stdout, stderr|
            stdout.each_line do |line|
              case line.chomp
              when "# Chef Name: #{@new_resource.name}"
                cron_found = true
                next
              when CRON_PATTERN
                if cron_found
                  cron_found = false
                  next
                end
              else
                next if cron_found
              end
              crontab << line
            end
          end

          status = write_crontab(crontab)
          Chef::Log.info("Deleted cron '#{@new_resource.name}'")
        end
      end

    end
  end
end
end
