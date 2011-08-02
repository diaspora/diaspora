require 'ostruct'

module PatronSpecHelper
  def http_request(method, uri, options = {}, &block)
    uri = Addressable::URI.heuristic_parse(uri)
    sess = Patron::Session.new
    sess.base_url = "#{uri.omit(:userinfo, :path, :query).normalize.to_s}".gsub(/\/$/,"")
    sess.username = uri.user
    sess.password = uri.password

    sess.connect_timeout = 10
    sess.timeout = 10
   
    response = sess.request(method, "#{uri.path}#{uri.query ? '?' : ''}#{uri.query}", options[:headers] || {}, {
      :data => options[:body]
    })
    headers = {}
    if response.headers
      response.headers.each do |k,v|
        v = v.join(", ") if v.is_a?(Array)
        headers[k] = v 
      end
    end
    OpenStruct.new({
      :body => response.body,
      :headers => WebMock::Util::Headers.normalize_headers(headers),
      :status => response.status.to_s,
      :message => response.status_line
    })
  end

  def client_timeout_exception_class
    Patron::TimeoutError
  end

  def connection_refused_exception_class
    Patron::ConnectionFailed
  end

  def setup_expectations_for_real_request(options = {})
    #TODO
  end

  def http_library
    :patron
  end

end
