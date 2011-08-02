module Gherkin
  module Rubify
    if defined?(JRUBY_VERSION)
      # Translate Java objects to Ruby.
      # This is especially important to convert java.util.List coming
      # from Java and back to a Ruby Array.
      def rubify(o)
        case(o)
        when Java.java.util.Collection, Array
          o.map{|e| rubify(e)}
        when Java.gherkin.formatter.model.DocString
          require 'gherkin/formatter/model'
          Formatter::Model::DocString.new(o.value, o.line)
        else
          o
        end
      end
    else
      def rubify(o)
        o
      end
    end
  end
end