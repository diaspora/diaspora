module Bunny
  
=begin rdoc

=== DESCRIPTION:

*Exchanges* are the routing and distribution hub of AMQP. All messages that Bunny sends
to an AMQP broker/server _have_ to pass through an exchange in order to be routed to a
destination queue. The AMQP specification defines the types of exchange that you can create.

At the time of writing there are four (4) types of exchange defined -

* <tt>:direct</tt>
* <tt>:fanout</tt>
* <tt>:topic</tt>
* <tt>:headers</tt>

AMQP-compliant brokers/servers are required to provide default exchanges for the _direct_ and
_fanout_ exchange types. All default exchanges are prefixed with <tt>'amq.'</tt>, for example -

* <tt>amq.direct</tt>
* <tt>amq.fanout</tt>
* <tt>amq.topic</tt>
* <tt>amq.match</tt> or <tt>amq.headers</tt>

If you want more information about exchanges, please consult the documentation for your
target broker/server or visit the {AMQP website}[http://www.amqp.org] to find the version of the
specification that applies to your target broker/server.

=end
  
  class Exchange

    attr_reader :client, :type, :name, :opts, :key

    def initialize(client, name, opts = {})
      # check connection to server
      raise Bunny::ConnectionError, 'Not connected to server' if client.status == :not_connected
    
      @client, @name, @opts = client, name, opts
  
      # set up the exchange type catering for default names
      if name.match(/^amq\./)
        new_type = name.sub(/amq\./, '')
        # handle 'amq.match' default
        new_type = 'headers' if new_type == 'match'
        @type = new_type.to_sym
      else
        @type = opts[:type] || :direct
      end
      
      @key = opts[:key]
      @client.exchanges[@name] ||= self
      
      # ignore the :nowait option if passed, otherwise program will hang waiting for a
      # response that will not be sent by the server
      opts.delete(:nowait)
      
      unless name == "amq.#{type}" or name == ''
        client.send_frame(
          Qrack::Protocol::Exchange::Declare.new(
            { :exchange => name, :type => type, :nowait => false }.merge(opts)
          )
        )

				method = client.next_method

				client.check_response(method, Qrack::Protocol::Exchange::DeclareOk,
				 	"Error declaring exchange #{name}: type = #{type}")

      end
    end

=begin rdoc

=== DESCRIPTION:

Requests that an exchange is deleted from broker/server. Removes reference from exchanges
if successful. If an error occurs raises _Bunny_::_ProtocolError_.

==== Options:

* <tt>:if_unused => true or false (_default_)</tt> - If set to _true_, the server will only
  delete the exchange if it has no queue bindings. If the exchange has queue bindings the
  server does not delete it but raises a channel exception instead.
* <tt>:nowait => true or false (_default_)</tt> - Ignored by Bunny, always _false_.

==== Returns:

<tt>:delete_ok</tt> if successful
=end

    def delete(opts = {})
      # ignore the :nowait option if passed, otherwise program will hang waiting for a
      # response that will not be sent by the server
      opts.delete(:nowait)

      client.send_frame(
        Qrack::Protocol::Exchange::Delete.new({ :exchange => name, :nowait => false }.merge(opts))
      )

			method = client.next_method

			client.check_response(method, Qrack::Protocol::Exchange::DeleteOk,
			 	"Error deleting exchange #{name}")

      client.exchanges.delete(name)

      # return confirmation
      :delete_ok
    end

=begin rdoc

=== DESCRIPTION:

Publishes a message to a specific exchange. The message will be routed to queues as defined
by the exchange configuration and distributed to any active consumers when the transaction,
if any, is committed.

==== OPTIONS:

* <tt>:key => 'routing_key'</tt> - Specifies the routing key for the message. The routing key is
  used for routing messages depending on the exchange configuration.
* <tt>:mandatory => true or false (_default_)</tt> - Tells the server how to react if the message
  cannot be routed to a queue. If set to _true_, the server will return an unroutable message
  with a Return method. If this flag is zero, the server silently drops the message.
* <tt>:immediate => true or false (_default_)</tt> - Tells the server how to react if the message
  cannot be routed to a queue consumer immediately. If set to _true_, the server will return an
  undeliverable message with a Return method. If set to _false_, the server will queue the message,
  but with no guarantee that it will ever be consumed.
* <tt>:persistent => true or false (_default_)</tt> - Tells the server whether to persist the message
  If set to _true_, the message will be persisted to disk and not lost if the server restarts. 
  If set to _false_, the message will not be persisted across server restart. Setting to _true_ 
  incurs a performance penalty as there is an extra cost associated with disk access.

==== RETURNS:

nil

=end

    def publish(data, opts = {})
      opts = opts.dup
      out = []

			# Set up options
			routing_key = opts.delete(:key) || key
			mandatory = opts.delete(:mandatory)
			immediate = opts.delete(:immediate)
			delivery_mode = opts.delete(:persistent) ? 2 : 1

      out << Qrack::Protocol::Basic::Publish.new(
        { :exchange => name,
					:routing_key => routing_key,
					:mandatory => mandatory,
					:immediate => immediate }
      )
      data = data.to_s
      out << Qrack::Protocol::Header.new(
        Qrack::Protocol::Basic,
        data.length, {
          :content_type  => 'application/octet-stream',
          :delivery_mode => delivery_mode,
          :priority      => 0 
        }.merge(opts)
      )
      out << Qrack::Transport::Body.new(data)

      client.send_frame(*out)
    end

  end
  
end
