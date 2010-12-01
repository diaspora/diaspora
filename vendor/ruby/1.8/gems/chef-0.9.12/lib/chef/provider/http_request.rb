#
# Author:: Adam Jacob (<adam@opscode.com>)
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

require 'tempfile'

class Chef
  class Provider
    class HttpRequest < Chef::Provider
      
      attr_accessor :rest
      
      def load_current_resource
        @rest = Chef::REST.new(@new_resource.url, nil, nil)
      end

      # Send a HEAD request to @new_resource.url, with ?message=@new_resource.message
      def action_head
        message = check_message(@new_resource.message)
        modified = @rest.run_request(
          :HEAD,
          @rest.create_url("#{@new_resource.url}?message=#{message}"),
          @new_resource.headers,
          false,
          10,
          false
        )
        @new_resource.updated_by_last_action(modified)
        Chef::Log.info("#{@new_resource} HEAD to #{@new_resource.url} successful")
        Chef::Log.debug("#{@new_resource} HEAD request response: #{modified}")
      end

      # Send a GET request to @new_resource.url, with ?message=@new_resource.message
      def action_get  
        message = check_message(@new_resource.message)
        body = @rest.run_request(
          :GET, 
          @rest.create_url("#{@new_resource.url}?message=#{message}"),
          @new_resource.headers,
          false,
          10,
          false
        )
        @new_resource.updated_by_last_action(true)
        Chef::Log.info("#{@new_resource} GET to #{@new_resource.url} successful")
        Chef::Log.debug("#{@new_resource} GET request response: #{body}")
      end
      
      # Send a PUT request to @new_resource.url, with the message as the payload
      def action_put 
        message = check_message(@new_resource.message)
        body = @rest.run_request(
          :PUT,
          @rest.create_url("#{@new_resource.url}"),
          @new_resource.headers,
          message,
          10,
          false
        )
        @new_resource.updated_by_last_action(true)
        Chef::Log.info("#{@new_resource} PUT to #{@new_resource.url} successful")
        Chef::Log.debug("#{@new_resource} PUT request response: #{body}")
      end
      
      # Send a POST request to @new_resource.url, with the message as the payload
      def action_post
        message = check_message(@new_resource.message)
        body = @rest.run_request(
          :POST,
          @rest.create_url("#{@new_resource.url}"),
          @new_resource.headers,
          message,
          10,
          false
        )
        @new_resource.updated_by_last_action(true)
        Chef::Log.info("#{@new_resource} POST to #{@new_resource.url} message: #{message.inspect} successful")
        Chef::Log.debug("#{@new_resource} POST request response: #{body}")
      end
      
      # Send a DELETE request to @new_resource.url
      def action_delete
        body = @rest.run_request(
          :DELETE,
          @rest.create_url("#{@new_resource.url}"),
          @new_resource.headers,
          false,
          10,
          false
        )
        @new_resource.updated_by_last_action(true)
        Chef::Log.info("#{@new_resource} DELETE to #{@new_resource.url} successful")
        Chef::Log.debug("#{@new_resource} DELETE request response: #{body}")
      end
      
      private
        
        def check_message(message)
          if message.kind_of?(Proc)
            message.call
          else
            message
          end
        end
      
    end
  end
end
