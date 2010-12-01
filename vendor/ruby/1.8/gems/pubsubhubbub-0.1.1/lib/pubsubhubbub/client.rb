# #--
# Copyright (C)2009 Ilya Grigorik
#
# You can redistribute this under the terms of the Ruby
# #--

module EventMachine
  class PubSubHubbub
    include EventMachine::Deferrable

    HEADERS = {"User-Agent" => "PubSubHubbub Ruby", "Content-Type" => "application/x-www-form-urlencoded"}

    def initialize(hub)
      @hub = hub.kind_of?(URI) ? hub : URI::parse(hub)
    end

    def publish(*feeds)
      data = feeds.flatten.collect do |feed|
        {'hub.url' => feed, 'hub.mode' => 'publish'}.to_params
      end.join("&")

      request(:body => data, :head => HEADERS)
    end

    # These command will work only if the callback URL supports confirmation.
    def subscribe(feed, callback, options = {});   command('subscribe', feed, callback, options);   end
    def unsubscribe(feed, callback, options = {}); command('unsubscribe', feed, callback, options); end

    private

      def command(cmd, feed, callback, options)
        options['hub.verify'] ||= "sync"
        params = {'hub.topic' => feed, 'hub.mode' => cmd, 'hub.callback' => callback}.merge(options).to_params

        request(:body => params, :head => HEADERS)
      end

      def request(opts)
        r = http_request(opts)

        r.callback do
          if r.response_header.status == 204
            succeed r
          else
            fail r
          end
        end

        r.errback { fail }
        r

      end

      def http_request(opts)
        EventMachine::HttpRequest.new(@hub).post opts
      end
  end
end
