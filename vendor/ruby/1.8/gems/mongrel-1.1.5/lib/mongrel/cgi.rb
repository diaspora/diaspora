# Copyright (c) 2005 Zed A. Shaw 
# You can redistribute it and/or modify it under the same terms as Ruby.
#
# Additional work donated by contributors.  See http://mongrel.rubyforge.org/attributions.html 
# for more information.

require 'cgi'

module Mongrel
  # The beginning of a complete wrapper around Mongrel's internal HTTP processing
  # system but maintaining the original Ruby CGI module.  Use this only as a crutch
  # to get existing CGI based systems working.  It should handle everything, but please
  # notify me if you see special warnings.  This work is still very alpha so I need 
  # testers to help work out the various corner cases.
  #
  # The CGIWrapper.handler attribute is normally not set and is available for 
  # frameworks that need to get back to the handler.  Rails uses this to give
  # people access to the RailsHandler#files (DirHandler really) so they can
  # look-up paths and do other things with the files managed there.
  #
  # In Rails you can get the real file for a request with:
  #
  #  path = @request.cgi.handler.files.can_serve(@request['PATH_INFO'])
  #
  # Which is ugly but does the job.  Feel free to write a Rails helper for that.
  # Refer to DirHandler#can_serve for more information on this.
  class CGIWrapper < ::CGI
    public :env_table
    attr_reader :options
    attr_accessor :handler
    # Set this to false if you want calls to CGIWrapper.out to not actually send
    # the response until you force it.
    attr_accessor :default_really_final

    # these are stripped out of any keys passed to CGIWrapper.header function
    REMOVED_KEYS = [ "nph","status","server","connection","type",
                     "charset","length","language","expires"]

    # Takes an HttpRequest and HttpResponse object, plus any additional arguments
    # normally passed to CGI.  These are used internally to create a wrapper around
    # the real CGI while maintaining Mongrel's view of the world.
    def initialize(request, response, *args)
      @request = request
      @response = response
      @args = *args
      @input = request.body
      @head = {}
      @out_called = false
      @default_really_final=true
      super(*args)
    end
    
    # The header is typically called to send back the header.  In our case we
    # collect it into a hash for later usage.
    #
    # nph -- Mostly ignored.  It'll output the date.
    # connection -- Completely ignored.  Why is CGI doing this?
    # length -- Ignored since Mongrel figures this out from what you write to output.
    # 
    def header(options = "text/html")
      # if they pass in a string then just write the Content-Type
      if options.class == String
        @head['Content-Type'] = options unless @head['Content-Type']
      else
        # convert the given options into what Mongrel wants
        @head['Content-Type'] = options['type'] || "text/html"
        @head['Content-Type'] += "; charset=" + options['charset'] if options.has_key? "charset" if options['charset']
        
        # setup date only if they use nph
        @head['Date'] = CGI::rfc1123_date(Time.now) if options['nph']

        # setup the server to use the default or what they set
        @head['Server'] = options['server'] || env_table['SERVER_SOFTWARE']

        # remaining possible options they can give
        @head['Status'] = options['status'] if options['status']
        @head['Content-Language'] = options['language'] if options['language']
        @head['Expires'] = options['expires'] if options['expires']

        # drop the keys we don't want anymore
        REMOVED_KEYS.each {|k| options.delete(k) }

        # finally just convert the rest raw (which puts 'cookie' directly)
        # 'cookie' is translated later as we write the header out
        options.each{|k,v| @head[k] = v}
      end

      # doing this fakes out the cgi library to think the headers are empty
      # we then do the real headers in the out function call later
      ""
    end

    # Takes any 'cookie' setting and sends it over the Mongrel header,
    # then removes the setting from the options. If cookie is an 
    # Array or Hash then it sends those on with .to_s, otherwise
    # it just calls .to_s on it and hopefully your "cookie" can
    # write itself correctly.
    def send_cookies(to)
      # convert the cookies based on the myriad of possible ways to set a cookie
      if @head['cookie']
        cookie = @head['cookie']
        case cookie
        when Array
          cookie.each {|c| to['Set-Cookie'] = c.to_s }
        when Hash
          cookie.each_value {|c| to['Set-Cookie'] = c.to_s}
        else
          to['Set-Cookie'] = options['cookie'].to_s
        end
        
        @head.delete('cookie')
      end
      
      # @output_cookies seems to never be used, but we'll process it just in case
      @output_cookies.each {|c| to['Set-Cookie'] = c.to_s } if @output_cookies
    end
    
    # The dumb thing is people can call header or this or both and in any order.
    # So, we just reuse header and then finalize the HttpResponse the right way.
    # Status is taken from the various options and converted to what Mongrel needs
    # via the CGIWrapper.status function.
    #
    # We also prevent Rails from actually doing the final send by adding a
    # second parameter "really_final".  Only Mongrel calls this after Rails
    # is done.  Since this will break other frameworks, it defaults to 
    # a different setting for rails (false) and (true) for others.
    def out(options = "text/html", really_final=@default_really_final)
      if @out_called || !really_final
        # don't do it more than once or if it's not the really final call
        return
      end

      header(options)

      @response.start status do |head, body|
        send_cookies(head)
        
        @head.each {|k,v| head[k] = v}
        body.write(yield || "")
      end

      @out_called = true
    end
    
    # Computes the status once, but lazily so that people who call header twice
    # don't get penalized.  Because CGI insists on including the options status 
    # message in the status we have to do a bit of parsing.
    def status
      if not @status
        stat = @head["Status"]
        stat = stat.split(' ')[0] if stat

        @status = stat || "200"
      end

      @status
    end

    # Used to wrap the normal args variable used inside CGI.
    def args
      @args
    end
    
    # Used to wrap the normal env_table variable used inside CGI.
    def env_table
      @request.params
    end
    
    # Used to wrap the normal stdinput variable used inside CGI.
    def stdinput
      @input
    end
    
    # The stdoutput should be completely bypassed but we'll drop a warning just in case
    def stdoutput
      STDERR.puts "WARNING: Your program is doing something not expected.  Please tell Zed that stdoutput was used and what software you are running.  Thanks."
      @response.body
    end    

  end
end
