module WebMock

  module Util

    class Headers

      def self.normalize_headers(headers)
        return nil unless headers
        array = headers.map { |name, value|
          [name.to_s.split(/_|-/).map { |segment| segment.capitalize }.join("-"),
           case value
            when Regexp then value
            when Array then (value.size == 1) ? value.first : value.map {|v| v.to_s}.sort
            else value.to_s
           end
          ]
        }
        Hash[*array.inject([]) {|r,x| r + x}]
      end

      def self.sorted_headers_string(headers)
        headers = WebMock::Util::Headers.normalize_headers(headers)
        str = '{'
        str << headers.map do |k,v|
          v = case v
            when Regexp then v.inspect
            when Array then "["+v.map{|v| "'#{v.to_s}'"}.join(", ")+"]"
            else "'#{v.to_s}'"
          end    
          "'#{k}'=>#{v}"
        end.sort.join(", ") 
        str << '}'
      end
      
      def self.decode_userinfo_from_header(header)
        header.sub(/^Basic /, "").unpack("m").first
      end

    end

  end

end
