# encoding: utf-8

require 'eventmachine' unless defined? EventMachine
require 'mysql2' unless defined? Mysql2

module Mysql2
  module EM
    class Client < ::Mysql2::Client
      module Watcher
        def initialize(client, deferable)
          @client = client
          @deferable = deferable
        end

        def notify_readable
          detach
          begin
            @deferable.succeed(@client.async_result)
          rescue Exception => e
            @deferable.fail(e)
          end
        end
      end

      def query(sql, opts={})
        super(sql, opts.merge(:async => true))
        deferable = ::EM::DefaultDeferrable.new
        ::EM.watch(self.socket, Watcher, self, deferable).notify_readable = true
        deferable
      end
    end
  end
end