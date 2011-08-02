module OAuth
  class Unauthorized < OAuth::Error
    attr_reader :request
    def initialize(request = nil)
      @request = request
    end

    def to_s
      [request.code, request.message] * " "
    end
  end
end
