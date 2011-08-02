module Capistrano
  module Processable
    module SessionAssociation
      def self.on(exception, session)
        unless exception.respond_to?(:session)
          exception.extend(self)
          exception.session = session
        end

        return exception
      end

      attr_accessor :session
    end

    def process_iteration(wait=nil, &block)
      ensure_each_session { |session| session.preprocess }

      return false if block && !block.call(self)

      readers = sessions.map { |session| session.listeners.keys }.flatten.reject { |io| io.closed? }
      writers = readers.select { |io| io.respond_to?(:pending_write?) && io.pending_write? }

      if readers.any? || writers.any?
        readers, writers, = IO.select(readers, writers, nil, wait)
      end

      if readers
        ensure_each_session do |session|
          ios = session.listeners.keys
          session.postprocess(ios & readers, ios & writers)
        end
      end

      true
    end

    def ensure_each_session
      errors = []

      sessions.each do |session|
        begin
          yield session
        rescue Exception => error
          errors << SessionAssociation.on(error, session)
        end
      end

      raise errors.first if errors.any?
      sessions
    end
  end
end