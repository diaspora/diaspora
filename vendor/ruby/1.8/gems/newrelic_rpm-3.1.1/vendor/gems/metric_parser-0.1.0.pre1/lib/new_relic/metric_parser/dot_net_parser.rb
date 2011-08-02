module NewRelic
  module MetricParser
    module DotNetParser
      def class_name_without_package
        full_class_name =~ /(.*\.)(.*)$/ ? $2 : full_class_name
      end

      def developer_name
        "#{full_class_name}.#{method_name}()"
      end

      def short_name
        "#{class_name_without_package}.#{method_name}()"
      end
    end
  end
end
