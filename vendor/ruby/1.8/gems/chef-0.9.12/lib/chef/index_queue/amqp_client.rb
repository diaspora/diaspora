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
    class AmqpClient
      include Singleton

      def initialize
        reset!
      end

      def reset!
        @amqp_client && amqp_client.connected? && amqp_client.stop
        @amqp_client = nil
        @exchange = nil
        @queue = nil
      end
      
      def stop
        @queue && @queue.subscription && @queue.unsubscribe
        @amqp_client && @amqp_client.stop
      end
      
      def amqp_client
        unless @amqp_client
          begin
            @amqp_client = Bunny.new(amqp_opts)
            Chef::Log.debug "Starting AMQP connection with client settings: #{@amqp_client.inspect}"
            @amqp_client.start
            @amqp_client.qos(:prefetch_count => 1)
          rescue Bunny::ServerDownError => e
            Chef::Log.fatal "Could not connect to rabbitmq. Is it running, reachable, and configured correctly?"
            raise e
          rescue Bunny::ProtocolError => e
            Chef::Log.fatal "Connection to rabbitmq refused. Check your rabbitmq configuration and chef's amqp* settings"
            raise e
          end
        end
        @amqp_client
      end

      def exchange
        @exchange ||= amqp_client.exchange("chef-indexer", :durable => true, :type => :fanout)
      end
      
      def queue
        unless @queue
          @queue = amqp_client.queue("chef-index-consumer-" + consumer_id, :durable => durable_queue?)
          @queue.bind(exchange)
        end
        @queue
      end
      
      def disconnected!
        Chef::Log.error("Disconnected from the AMQP Broker (RabbitMQ)")
        @amqp_client = nil
        reset!
      end

      def send_action(action, data)
        retries = 0
        begin
          exchange.publish({"action" => action.to_s, "payload" => data}.to_json)
        rescue Bunny::ServerDownError, Bunny::ConnectionError, Errno::ECONNRESET
          disconnected!
          if (retries += 1) < 2
            Chef::Log.info("Attempting to reconnect to the AMQP broker")
            retry
          else
            Chef::Log.fatal("Could not re-connect to the AMQP broker, giving up")
            raise
          end
        end
      end

      private
      
      def durable_queue?
        !!Chef::Config[:amqp_consumer_id]
      end
      
      def consumer_id
        Chef::Config[:amqp_consumer_id] || UUIDTools::UUID.random_create.to_s
      end

      def amqp_opts
        { :spec   => '08',
          :host   => Chef::Config[:amqp_host],
          :port   => Chef::Config[:amqp_port],
          :user   => Chef::Config[:amqp_user],
          :pass   => Chef::Config[:amqp_pass],
          :vhost  => Chef::Config[:amqp_vhost]}
      end

    end
  end
end