#!/usr/local/bin/ruby
require 'webrick'
include WEBrick

s = HTTPServer.new( :Port => 4000 )

# HTTPServer#mount(path, servletclass)
#   When a request referring "/hello" is received,
#   the HTTPServer get an instance of servletclass
#   and then call a method named do_"a HTTP method".

class HelloServlet < HTTPServlet::AbstractServlet
  def do_GET(req, res)
    res.body = "hello!"
    res['Content-Type'] = "text/html"
  end
end
s.mount("/test", HelloServlet)

s.start