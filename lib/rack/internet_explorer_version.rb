#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Rack
  class InternetExplorerVersion
    def initialize(app, options={})
      @app = app
      @options = options
    end

    def call(env)
      if env["HTTP_USER_AGENT"] =~ /MSIE/ && ie_version(env["HTTP_USER_AGENT"]) < @options[:minimum]
        html = <<-HTML
          <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
          <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
            <head>
              <meta http-equiv="content-type" content="text/html;charset=UTF-8" />
              <title>Diaspora doesn't support your version of Internet Explorer. Try Firefox, Chrome or Opera!</title>
            </head>
            <body>
              <h1>Diaspora doesn't support your version of Internet Explorer.</h1>
              You can use one of these browsers (and many more):
              <ul>
                <li><a href="https://www.mozilla.org/firefox/">Firefox</a></li>
                <li><a href="https://www.google.com/chrome/">Chrome</a></li>
                <li><a href="https://www.opera.com/">Opera</a></li>
              </ul>
            </body>
          </html>
        HTML
        return [200, {"Content-Type" =>  "text/html", "Content-Length" => html.size.to_s}, Rack::Response.new([html])]
      end
      @app.call(env)
    end

    def ie_version(ua_string)
      ua_string.match(/MSIE ?(\S+)/)[1].to_f
    end
  end
end
