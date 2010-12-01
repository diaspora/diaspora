#
# Author:: Adam Jacob (<adam@opscode.com>)
# Copyright:: Copyright (c) 2010 Opscode, Inc.
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

require 'chef/handler'
require 'chef/resource/directory'

class Chef
  class Handler
    class JsonFile < ::Chef::Handler

      attr_reader :config

      def initialize(config={})
        @config = config
        @config[:path] ||= "/var/chef/reports"
        @config
      end

      def report
        if exception
          Chef::Log.error("Creating JSON exception report")
        else
          Chef::Log.info("Creating JSON run report")
        end

        build_report_dir
        savetime = Time.now.strftime("%Y%m%d%H%M%S")
        File.open(File.join(config[:path], "chef-run-report-#{savetime}.json"), "w") do |file|
          file.puts JSON.pretty_generate(data)
        end
      end

      def build_report_dir
        unless File.exists?(config[:path])
          FileUtils.mkdir_p(config[:path])
          File.chmod(00700, config[:path])
        end
      end


    end
  end
end
