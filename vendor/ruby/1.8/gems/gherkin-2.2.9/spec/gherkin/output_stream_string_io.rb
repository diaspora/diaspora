if defined?(JRUBY_VERSION)
  class WriterStringIO < Java.java.io.StringWriter
    def write(what)
      super(Java.java.lang.String.new(what.to_s))
    end

    def string
      toString()
    end
  end

  require 'stringio'
  class StringIO
    class << self
      def new
        WriterStringIO.new
      end
    end
  end
end
