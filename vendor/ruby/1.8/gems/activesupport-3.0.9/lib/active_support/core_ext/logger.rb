require 'active_support/core_ext/class/attribute_accessors'

# Adds the 'around_level' method to Logger.
class Logger #:nodoc:
  def self.define_around_helper(level)
    module_eval <<-end_eval, __FILE__, __LINE__ + 1
      def around_#{level}(before_message, after_message, &block)  # def around_debug(before_message, after_message, &block)
        self.#{level}(before_message)                             #   self.debug(before_message)
        return_value = block.call(self)                           #   return_value = block.call(self)
        self.#{level}(after_message)                              #   self.debug(after_message)
        return return_value                                       #   return return_value
      end                                                         # end
    end_eval
  end
  [:debug, :info, :error, :fatal].each {|level| define_around_helper(level) }
end


require 'logger'

# Extensions to the built-in Ruby logger.
#
# If you want to use the default log formatter as defined in the Ruby core, then you
# will need to set the formatter for the logger as in:
#
#   logger.formatter = Formatter.new
#
# You can then specify the datetime format, for example:
#
#   logger.datetime_format = "%Y-%m-%d"
#
# Note: This logger is deprecated in favor of ActiveSupport::BufferedLogger
class Logger
  ##
  # :singleton-method:
  # Set to false to disable the silencer
  cattr_accessor :silencer
  self.silencer = true

  # Silences the logger for the duration of the block.
  def silence(temporary_level = Logger::ERROR)
    if silencer
      begin
        old_logger_level, self.level = level, temporary_level
        yield self
      ensure
        self.level = old_logger_level
      end
    else
      yield self
    end
  end

  alias :old_datetime_format= :datetime_format=
  # Logging date-time format (string passed to +strftime+). Ignored if the formatter
  # does not respond to datetime_format=.
  def datetime_format=(datetime_format)
    formatter.datetime_format = datetime_format if formatter.respond_to?(:datetime_format=)
  end

  alias :old_datetime_format :datetime_format
  # Get the logging datetime format. Returns nil if the formatter does not support
  # datetime formatting.
  def datetime_format
    formatter.datetime_format if formatter.respond_to?(:datetime_format)
  end

  alias :old_formatter :formatter if method_defined?(:formatter)
  # Get the current formatter. The default formatter is a SimpleFormatter which only
  # displays the log message
  def formatter
    @formatter ||= SimpleFormatter.new
  end

  # Simple formatter which only displays the message.
  class SimpleFormatter < Logger::Formatter
    # This method is invoked when a log event occurs
    def call(severity, timestamp, progname, msg)
      "#{String === msg ? msg : msg.inspect}\n"
    end
  end

  private
    alias old_format_message format_message

    # Ruby 1.8.3 transposed the msg and progname arguments to format_message.
    # We can't test RUBY_VERSION because some distributions don't keep Ruby
    # and its standard library in sync, leading to installations of Ruby 1.8.2
    # with Logger from 1.8.3 and vice versa.
    if method_defined?(:formatter=)
      def format_message(severity, timestamp, progname, msg)
        formatter.call(severity, timestamp, progname, msg)
      end
    else
      def format_message(severity, timestamp, msg, progname)
        formatter.call(severity, timestamp, progname, msg)
      end

      attr_writer :formatter
      public :formatter=

      alias old_format_datetime format_datetime
      def format_datetime(datetime) datetime end

      alias old_msg2str msg2str
      def msg2str(msg) msg end
    end
end
