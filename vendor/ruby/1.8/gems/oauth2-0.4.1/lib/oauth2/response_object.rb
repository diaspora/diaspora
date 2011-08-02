module OAuth2
  module ResponseObject
    def self.from(response)
      object = MultiJson.decode(response.body)

      case object
        when Array
          ResponseArray.new(response, object)
        when Hash
          ResponseHash.new(response, object)
        else
          ResponseString.new(response)
      end
    rescue
      ResponseString.new(response)
    end

    def self.included(base)
      base.class_eval do
        attr_accessor :response
      end
    end

    def headers; response.headers end
    def status; response.status end
  end

  class ResponseHash < Hash
    include ResponseObject

    def initialize(response, hash)
      self.response = response
      hash.keys.each{|k| self[k] = hash[k]}
    end
  end

  class ResponseArray < Array
    include ResponseObject

    def initialize(response, array)
      self.response = response
      super(array)
    end
  end

  # This special String class is returned from HTTP requests
  # and contains the original full response along with convenience
  # methods for accessing the HTTP status code and headers. It
  # is returned from all access token requests.
  class ResponseString < String
    include ResponseObject

    def initialize(response)
      super(response.body.to_s)
      self.response = response
    end
  end
end
