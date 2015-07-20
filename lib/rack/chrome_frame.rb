#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Rack
  class ChromeFrame

    def initialize(app, options={})
      @app = app
      @options = options
    end

    def call(env)

      if env['HTTP_USER_AGENT'] =~ /MSIE/
        if env['HTTP_USER_AGENT'] =~ /chromeframe/
          status, headers, response = @app.call(env)
          new_body = insert_tag(build_response_body(response))
          new_headers = recalculate_body_length(headers, new_body)
          return [status, new_headers, [new_body]]
        elsif @options[:minimum].nil? or ie_version(env['HTTP_USER_AGENT']) < @options[:minimum]
          html = <<-HTML
            <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
            <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
              <head>
                <meta http-equiv="content-type" content="text/html;charset=UTF-8" />
                <title>Diaspora doesn't support your version of Internet Explorer.  Try Chrome, Firefox, or Opera!</title>
              </head>
              <body>
                <div id="cf-placeholder"></div>
                <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/chrome-frame/1/CFInstall.min.js"></script>
                <script>CFInstall.check({ node: "cf-placeholder" #{', destination: "' + @options[:destination] + '" ' if @options[:destination]}});</script>
              </body>
            </html>
          HTML
          return [200, {'Content-Type' =>  'text/html', 'Content-Length' => html.size.to_s}, Rack::Response.new([html])]
        end
      end
      @app.call(env)
    end

    def build_response_body(response)
      response_body = ""
      response.each { |part| response_body += part }

      # see: http://johnbintz.github.com/blog/2012/03/05/closing-given-body-in-rack-middleware/
      response.close if response.respond_to?(:close)

      response_body
    end

    def recalculate_body_length(headers, body)
      new_headers = headers
      new_headers["Content-Length"] = body.length.to_s
      new_headers
    end

    def insert_tag(body)
      head = <<-HEAD
        <meta http-equiv="X-UA-Compatible" content="chrome=1">
      HEAD

      body.gsub!(/<head(.*)>/, "<head\\1>\n" + head )
      body
    end

    def ie_version(ua_string)
      ua_string.match(/MSIE ?(\S+)/)[1].to_f
    end
  end
end
