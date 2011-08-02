require 'net/scp'
require 'net/sftp'

require 'capistrano/processable'

module Capistrano
  class Transfer
    include Processable

    def self.process(direction, from, to, sessions, options={}, &block)
      new(direction, from, to, sessions, options, &block).process!
    end

    attr_reader :sessions
    attr_reader :options
    attr_reader :callback

    attr_reader :transport
    attr_reader :direction
    attr_reader :from
    attr_reader :to

    attr_reader :logger
    attr_reader :transfers

    def initialize(direction, from, to, sessions, options={}, &block)
      @direction = direction
      @from      = from
      @to        = to
      @sessions  = sessions
      @options   = options
      @callback  = block

      @transport = options.fetch(:via, :sftp)
      @logger    = options.delete(:logger)

      @session_map = {}

      prepare_transfers
    end

    def process!
      loop do
        begin
          break unless process_iteration { active? }
        rescue Exception => error
          if error.respond_to?(:session)
            handle_error(error)
          else
            raise
          end
        end
      end

      failed = transfers.select { |txfr| txfr[:failed] }
      if failed.any?
        hosts = failed.map { |txfr| txfr[:server] }
        errors = failed.map { |txfr| "#{txfr[:error]} (#{txfr[:error].message})" }.uniq.join(", ")
        error = TransferError.new("#{operation} via #{transport} failed on #{hosts.join(',')}: #{errors}")
        error.hosts = hosts

        logger.important(error.message) if logger
        raise error
      end

      logger.debug "#{transport} #{operation} complete" if logger
      self
    end

    def active?
      transfers.any? { |transfer| transfer.active? }
    end

    def operation
      "#{direction}load"
    end

    def sanitized_from
      if from.responds_to?(:read)
        "#<#{from.class}>"
      else
        from
      end
    end

    def sanitized_to
      if to.responds_to?(:read)
        "#<#{to.class}>"
      else
        to
      end
    end

    private

      def session_map
        @session_map
      end

      def prepare_transfers
        logger.info "#{transport} #{operation} #{from} -> #{to}" if logger

        @transfers = sessions.map do |session|
          session_from = normalize(from, session)
          session_to   = normalize(to, session)

          session_map[session] = case transport
            when :sftp
              prepare_sftp_transfer(session_from, session_to, session)
            when :scp
              prepare_scp_transfer(session_from, session_to, session)
            else
              raise ArgumentError, "unsupported transport type: #{transport.inspect}"
            end
        end
      end

      def prepare_scp_transfer(from, to, session)
        real_callback = callback || Proc.new do |channel, name, sent, total|
          logger.trace "[#{channel[:host]}] #{name}" if logger && sent == 0
        end

        channel = case direction
          when :up
            session.scp.upload(from, to, options, &real_callback)
          when :down
            session.scp.download(from, to, options, &real_callback)
          else
            raise ArgumentError, "unsupported transfer direction: #{direction.inspect}"
          end

        channel[:server] = session.xserver
        channel[:host]   = session.xserver.host

        return channel
      end

      class SFTPTransferWrapper
        attr_reader :operation

        def initialize(session, &callback)
          session.sftp(false).connect do |sftp|
            @operation = callback.call(sftp)
          end
        end

        def active?
          @operation.nil? || @operation.active?
        end

        def [](key)
          @operation[key]
        end

        def []=(key, value)
          @operation[key] = value
        end

        def abort!
          @operation.abort!
        end
      end

      def prepare_sftp_transfer(from, to, session)
        SFTPTransferWrapper.new(session) do |sftp|
          real_callback = Proc.new do |event, op, *args|
            if callback
              callback.call(event, op, *args)
            elsif event == :open
              logger.trace "[#{op[:host]}] #{args[0].remote}"
            elsif event == :finish
              logger.trace "[#{op[:host]}] done"
            end
          end

          opts = options.dup
          opts[:properties] = (opts[:properties] || {}).merge(
            :server  => session.xserver,
            :host    => session.xserver.host)

          case direction
          when :up
            sftp.upload(from, to, opts, &real_callback)
          when :down
            sftp.download(from, to, opts, &real_callback)
          else
            raise ArgumentError, "unsupported transfer direction: #{direction.inspect}"
          end
        end
      end

      def normalize(argument, session)
        if argument.is_a?(String)
          argument.gsub(/\$CAPISTRANO:HOST\$/, session.xserver.host)
        elsif argument.respond_to?(:read)
          pos = argument.pos
          clone = StringIO.new(argument.read)
          clone.pos = argument.pos = pos
          clone
        else
          argument
        end
      end

      def handle_error(error)
        transfer = session_map[error.session]
        transfer[:error] = error
        transfer[:failed] = true

        case transport
        when :sftp then transfer.abort!
        when :scp  then transfer.close
        end
      end
  end
end
