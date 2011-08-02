require 'rack'

module NewRelic::Rack
  class BrowserMonitoring

    def initialize(app, options = {})
      @app = app
    end

    # method required by Rack interface
    def call(env)
      
      # clear out the thread locals we use in case this is a static request
      Thread.current[:newrelic_most_recent_transaction] = nil
      Thread.current[:newrelic_start_time] = Time.now
      Thread.current[:newrelic_queue_time] = 0
      
      result = @app.call(env)   # [status, headers, response]

      if (NewRelic::Agent.browser_timing_header != "") && should_instrument?(result[0], result[1])
        response_string = autoinstrument_source(result[2], result[1])

        if (response_string)
          Rack::Response.new(response_string, result[0], result[1]).finish
        else
          result
        end
      else
        result
      end
    end

    def should_instrument?(status, headers)
      status == 200 && headers["Content-Type"] && headers["Content-Type"].include?("text/html")
    end

    def autoinstrument_source(response, headers)
      source = nil
      response.each {|fragment| (source) ? (source << fragment) : (source = fragment)}
      return nil unless source
      
      body_start = source.index("<body")
      body_close = source.rindex("</body>")

      if body_start && body_close
        footer = NewRelic::Agent.browser_timing_footer
        header = NewRelic::Agent.browser_timing_header
                  
        if source.include?('X-UA-Compatible')
          # put at end of header if UA-Compatible meta tag found
          head_pos = source.index("</head>")          
        elsif head_open = source.index("<head")
          # put at the beginning of the header
          head_pos = source.index(">", head_open) + 1
        else
          # put the header right above body start
          head_pos = body_start
        end

        source = source[0..(head_pos-1)] + header + source[head_pos..(body_close-1)] + footer + source[body_close..-1]

        headers['Content-Length'] = source.length.to_s if headers['Content-Length']
      end

      source
    end
  end
end
