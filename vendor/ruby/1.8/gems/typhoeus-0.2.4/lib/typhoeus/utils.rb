module Typhoeus
  module Utils
    # Taken from Rack::Utils, 1.2.1 to remove Rack dependency.
    def escape(s)
      s.to_s.gsub(/([^ a-zA-Z0-9_.-]+)/u) {
        '%'+$1.unpack('H2'*bytesize($1)).join('%').upcase
      }.tr(' ', '+')
    end
    module_function :escape

    # Params are NOT escaped.
    def traverse_params_hash(hash, result = nil, current_key = nil)
      result ||= { :files => [], :params => [] }

      hash.keys.sort { |a, b| a.to_s <=> b.to_s }.collect do |key|
        new_key = (current_key ? "#{current_key}[#{key}]" : key).to_s
        case hash[key]
        when Hash
          traverse_params_hash(hash[key], result, new_key)
        when Array
          array_key = "#{new_key}[]"
          hash[key].each do |v|
            result[:params] << [array_key, v.to_s]
          end
        when File
          filename = File.basename(hash[key].path)
          types = MIME::Types.type_for(filename)
          result[:files] << [
            new_key,
            filename,
            types.empty? ? 'application/octet-stream' : types[0].to_s,
            File.expand_path(hash[key].path)
          ]
        else
          result[:params] << [new_key, hash[key].to_s]
        end
      end
      result
    end
    module_function :traverse_params_hash

    def traversal_to_param_string(traversal, escape = true)
      traversal[:params].collect { |param|
        "#{Typhoeus::Utils.escape(param[0])}=#{Typhoeus::Utils.escape(param[1])}"
      }.join('&')
    end
    module_function :traversal_to_param_string

    # Return the bytesize of String; uses String#size under Ruby 1.8 and
    # String#bytesize under 1.9.
    if ''.respond_to?(:bytesize)
      def bytesize(string)
        string.bytesize
      end
    else
      def bytesize(string)
        string.size
      end
    end
    module_function :bytesize
  end
end
