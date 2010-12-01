=begin
Copyright (c) 2007 RightScale, Inc. 

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
=end

# Stub extension/redefinition of RightHttpConnection for testing purposes.
require 'net/http'
require 'rubygems'
require 'right_http_connection'

module Net
  class HTTPResponse
  alias_method :real_body, :body
    def setmsg(msg)
      @mymsg = msg
    end

    def body
      # defined?() helps us to get rid of a bunch of 'warnings'
      (defined?(@mymsg) && @mymsg) ? @mymsg : real_body
    end
  end
end

module Rightscale

  class HttpConnection
    @@response_stack = []

    alias_method :real_request, :request

    def request(request_params, &block)
      if(@@response_stack.length == 0)
        return real_request(request_params, &block)
      end

      if(block)
        # Do something special
      else
        next_response = HttpConnection::pop() 
        classname = Net::HTTPResponse::CODE_TO_OBJ["#{next_response[:code]}"]
        response = classname.new("1.1", next_response[:code], next_response[:msg])
        if(next_response[:msg])
          response.setmsg(next_response[:msg])
        end
        response
      end
    end

    def self.reset
      @@response_stack = []
    end

    def self.push(code, msg=nil)
      response = {:code => code, :msg => msg}
      @@response_stack << response
    end

    def self.pop
      @@response_stack.pop
    end

    def self.length
      @@response_stack.length
    end

  end

end
