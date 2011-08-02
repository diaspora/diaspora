class Class
  class IOWriter < Java.java.io.Writer
    def initialize(io)
      @io = io
    end
    
    def write(cbuf, off, len)
      @io.write(cbuf.unpack("U*")[off..len].pack("U*"))
    end

    def flush
      @io.flush
    end

    def close
      @io.close
    end
  end

  def implements(java_class_name)
    # no-op
  end

  # Causes a Java class to be instantiated instead of the Ruby class when 
  # running on JRuby. This is used to test both pure Java and pure Ruby classes 
  # from the same Ruby based test suite. The Java Class must have a package name
  # that corresponds with the Ruby class.
  def native_impl(lib)
    require "#{lib}.jar"

    class << self
      def javaify(arg)
        if Array === arg
          arg.map{|a| javaify(a)}
        else
          case(arg)
          when Regexp
            java.util.regex.Pattern.compile(arg.source)
          when Symbol
            arg.to_s
          when IO
            IOWriter.new(arg)
          else
            arg
          end
        end
      end

      def new(*args)
        begin
          java_class.new(*javaify(args))
        rescue ArgumentError => e
          e.message << "\n#{java_class.name}"
          raise e
        rescue NameError => e
          e.message << "\n args: #{args.inspect}" 
          raise e
        end
      end

      def ===(object)
        super || object.java_kind_of?(java_class)
      end

      def java_class
        names = self.name.split('::')
        package = Java
        names[0..-2].each do |module_name|
          package = package.__send__(module_name.downcase)
        end

        package.__send__(names[-1])
      end
    end
  end
end