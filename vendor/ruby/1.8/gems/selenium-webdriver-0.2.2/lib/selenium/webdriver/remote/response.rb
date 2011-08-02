module Selenium
  module WebDriver
    module Remote

      # @api private
      class Response

        attr_reader :code, :payload
        attr_writer :payload

        def initialize(code, payload = nil)
          @code    = code
          @payload = payload || {}

          assert_ok
        end

        def error
          klass = Error.for_code(@payload['status']) || return

          ex = klass.new(error_message)
          ex.set_backtrace(caller)
          add_backtrace ex

          ex
        end

        def error_message
          val = @payload['value']
          msg = val['message'] or return ""

          msg << " (#{ val['class'] })" if val['class']

          msg
        end

        def [](key)
          @payload[key]
        end

        private

        def assert_ok
          if @code.nil? || @code >= 400
            if e = error()
              raise e
            else
              raise Error::ServerError, self
            end
          end
        end

        def add_backtrace(ex)
          return unless server_trace = @payload['value']['stackTrace']

          backtrace = server_trace.map do |frame|
            next unless frame.kind_of?(Hash)

            file = frame['fileName']
            line = frame['lineNumber']
            meth = frame['methodName']

            if class_name = frame['className']
              file = "#{class_name}(#{file})"
            end

            if meth.nil? || meth.empty?
              meth = 'unknown'
            end

            "[remote server] #{file}:#{line}:in `#{meth}'"
          end.compact

          ex.set_backtrace(backtrace + ex.backtrace)
        end

      end # Response
    end # Remote
  end # WebDriver
end # Selenium
