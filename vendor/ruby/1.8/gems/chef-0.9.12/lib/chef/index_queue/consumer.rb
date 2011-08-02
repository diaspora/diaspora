#
# Author:: Daniel DeLeo (<dan@kallistec.com>)
# Copyright:: Copyright (c) 2009 Daniel DeLeo
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

class Chef
  module IndexQueue
    module Consumer
      module ClassMethods
        def expose(*methods)
          @exposed_methods = Array(@exposed_methods)
          @exposed_methods += methods
        end
        
        def exposed_methods
          @exposed_methods || []
        end
        
        def whitelisted?(method_name)
          exposed_methods.include?(method_name)
        end
      end
      
      def self.included(including_class)
        including_class.send(:extend, ClassMethods)
      end
      
      def run
        Chef::Log.debug("Starting Index Queue Consumer")
        AmqpClient.instance.queue # triggers connection setup
        
        begin
          AmqpClient.instance.queue.subscribe(:ack => true, :timeout => false) do |message|
            call_action_for_message(message)
          end
        rescue Bunny::ConnectionError, Errno::ECONNRESET, Bunny::ServerDownError
          AmqpClient.instance.disconnected!
          Chef::Log.warn "Connection to rabbitmq lost. attempting to reconnect"
          sleep 1
          retry
        end
      end
      alias :start :run
      
      def call_action_for_message(message)
        amqp_payload  = JSON.parse(message[:payload], :create_additions => false, :max_nesting => false)
        action        = amqp_payload["action"].to_sym
        app_payload   = amqp_payload["payload"]
        assert_method_whitelisted(action)
        send(action, app_payload)
      end
      
      private
      
      def assert_method_whitelisted(method_name)
        unless self.class.whitelisted?(method_name)
          raise ArgumentError, "non-exposed method #{method_name} called via index queue"
        end
      end
      
    end
  end
end