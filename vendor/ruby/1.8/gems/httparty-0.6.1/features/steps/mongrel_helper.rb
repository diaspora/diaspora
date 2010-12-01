require 'base64'
class BasicMongrelHandler < Mongrel::HttpHandler
  attr_accessor :content_type, :custom_headers, :response_body, :response_code, :preprocessor, :username, :password

  def initialize
    @content_type = "text/html"
    @response_body = ""
    @response_code = 200
    @custom_headers = {}
  end

  def process(request, response)
    instance_eval &preprocessor if preprocessor
    reply_with(response, response_code, response_body)
  end

  def reply_with(response, code, response_body)
    response.start(code) do |head, body|
      head["Content-Type"] = content_type
      custom_headers.each { |k,v| head[k] = v }
      body.write(response_body)
    end
  end
end

class DeflateHandler < BasicMongrelHandler
  def process(request, response)
    response.start do |head, body|
      head['Content-Encoding'] = 'deflate'
      body.write Zlib::Deflate.deflate(response_body)
    end
  end
end

class GzipHandler < BasicMongrelHandler
  def process(request, response)
    response.start do |head, body|
      head['Content-Encoding'] = 'gzip'
      body.write gzip(response_body)
    end
  end

  protected

  def gzip(string)
    sio = StringIO.new('', 'r+')
    gz = Zlib::GzipWriter.new sio
    gz.write string
    gz.finish
    sio.rewind
    sio.read
  end
end

module BasicAuthentication
  def self.extended(base)
    base.custom_headers["WWW-Authenticate"] = 'Basic Realm="Super Secret Page"'
  end

  def process(request, response)
    if authorized?(request)
      super
    else
      reply_with(response, 401, "Incorrect.  You have 20 seconds to comply.")
    end
  end

  def authorized?(request)
    request.params["HTTP_AUTHORIZATION"] == "Basic " + Base64.encode64("#{@username}:#{@password}").strip
  end
end

module DigestAuthentication
  def self.extended(base)
    base.custom_headers["WWW-Authenticate"] = 'Digest realm="testrealm@host.com",qop="auth,auth-int",nonce="nonce",opaque="opaque"'
  end

  def process(request, response)
    if authorized?(request)
      super
    else
      reply_with(response, 401, "Incorrect.  You have 20 seconds to comply.")
    end
  end

  def authorized?(request)
    request.params["HTTP_AUTHORIZATION"] =~ /Digest.*uri=/
  end
end

def new_mongrel_redirector(target_url, relative_path = false)
  target_url = "http://#{@host_and_port}#{target_url}" unless relative_path
  Mongrel::RedirectHandler.new(target_url)
end
