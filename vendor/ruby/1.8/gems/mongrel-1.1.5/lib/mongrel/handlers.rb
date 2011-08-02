# Copyright (c) 2005 Zed A. Shaw 
# You can redistribute it and/or modify it under the same terms as Ruby.
#
# Additional work donated by contributors.  See http://mongrel.rubyforge.org/attributions.html 
# for more information.

require 'mongrel/stats'
require 'zlib'
require 'yaml'

module Mongrel

  # You implement your application handler with this.  It's very light giving
  # just the minimum necessary for you to handle a request and shoot back 
  # a response.  Look at the HttpRequest and HttpResponse objects for how
  # to use them.
  #
  # This is used for very simple handlers that don't require much to operate.
  # More extensive plugins or those you intend to distribute as GemPlugins 
  # should be implemented using the HttpHandlerPlugin mixin.
  #
  class HttpHandler
    attr_reader :request_notify
    attr_accessor :listener

    # This will be called by Mongrel if HttpHandler.request_notify set to *true*.
    # You only get the parameters for the request, with the idea that you'd "bound"
    # the beginning of the request processing and the first call to process.
    def request_begins(params)
    end

    # Called by Mongrel for each IO chunk that is received on the request socket
    # from the client, allowing you to track the progress of the IO and monitor
    # the input.  This will be called by Mongrel only if HttpHandler.request_notify
    # set to *true*.
    def request_progress(params, clen, total)
    end

    def process(request, response)
    end

  end


  # This is used when your handler is implemented as a GemPlugin.
  # The plugin always takes an options hash which you can modify
  # and then access later.  They are stored by default for 
  # the process method later.
  module HttpHandlerPlugin
    attr_reader :options
    attr_reader :request_notify
    attr_accessor :listener

    def request_begins(params)
    end

    def request_progress(params, clen, total)
    end

    def initialize(options={})
      @options = options
      @header_only = false
    end

    def process(request, response)
    end

  end


  #
  # The server normally returns a 404 response if an unknown URI is requested, but it
  # also returns a lame empty message.  This lets you do a 404 response
  # with a custom message for special URIs.
  #
  class Error404Handler < HttpHandler

    # Sets the message to return.  This is constructed once for the handler
    # so it's pretty efficient.
    def initialize(msg)
      @response = Const::ERROR_404_RESPONSE + msg
    end

    # Just kicks back the standard 404 response with your special message.
    def process(request, response)
      response.socket.write(@response)
    end

  end

  #
  # Serves the contents of a directory.  You give it the path to the root
  # where the files are located, and it tries to find the files based on 
  # the PATH_INFO inside the directory.  If the requested path is a
  # directory then it returns a simple directory listing.
  #
  # It does a simple protection against going outside it's root path by
  # converting all paths to an absolute expanded path, and then making 
  # sure that the final expanded path includes the root path.  If it doesn't
  # than it simply gives a 404.
  #
  # If you pass nil as the root path, it will not check any locations or
  # expand any paths. This lets you serve files from multiple drives
  # on win32. It should probably not be used in a public-facing way
  # without additional checks.
  #
  # The default content type is "text/plain; charset=ISO-8859-1" but you
  # can change it anything you want using the DirHandler.default_content_type
  # attribute.
  #
  class DirHandler < HttpHandler
    attr_accessor :default_content_type
    attr_reader :path

    MIME_TYPES_FILE = "mime_types.yml"
    MIME_TYPES = YAML.load_file(File.join(File.dirname(__FILE__), MIME_TYPES_FILE))

    ONLY_HEAD_GET="Only HEAD and GET allowed.".freeze

    # You give it the path to the directory root and and optional listing_allowed and index_html
    def initialize(path, listing_allowed=true, index_html="index.html")
      @path = File.expand_path(path) if path
      @listing_allowed = listing_allowed
      @index_html = index_html
      @default_content_type = "application/octet-stream".freeze
    end

    # Checks if the given path can be served and returns the full path (or nil if not).
    def can_serve(path_info)

      req_path = HttpRequest.unescape(path_info)
      # Add the drive letter or root path
      req_path = File.join(@path, req_path) if @path
      req_path = File.expand_path req_path
      
      if File.exist? req_path and (!@path or req_path.index(@path) == 0)
        # It exists and it's in the right location
        if File.directory? req_path
          # The request is for a directory
          index = File.join(req_path, @index_html)
          if File.exist? index
            # Serve the index
            return index
          elsif @listing_allowed
            # Serve the directory
            return req_path
          else
            # Do not serve anything
            return nil
          end
        else
          # It's a file and it's there
          return req_path
        end
      else
        # does not exist or isn't in the right spot
        return nil
      end
    end


    # Returns a simplistic directory listing if they're enabled, otherwise a 403.
    # Base is the base URI from the REQUEST_URI, dir is the directory to serve 
    # on the file system (comes from can_serve()), and response is the HttpResponse
    # object to send the results on.
    def send_dir_listing(base, dir, response)
      # take off any trailing / so the links come out right
      base = HttpRequest.unescape(base)
      base.chop! if base[-1] == "/"[-1]

      if @listing_allowed
        response.start(200) do |head,out|
          head[Const::CONTENT_TYPE] = "text/html"
          out << "<html><head><title>Directory Listing</title></head><body>"
          Dir.entries(dir).each do |child|
            next if child == "."
            out << "<a href=\"#{base}/#{ HttpRequest.escape(child)}\">"
            out << (child == ".." ? "Up to parent.." : child)
            out << "</a><br/>"
          end
          out << "</body></html>"
        end
      else
        response.start(403) do |head,out|
          out.write("Directory listings not allowed")
        end
      end
    end


    # Sends the contents of a file back to the user. Not terribly efficient since it's
    # opening and closing the file for each read.
    def send_file(req_path, request, response, header_only=false)

      stat = File.stat(req_path)

      # Set the last modified times as well and etag for all files
      mtime = stat.mtime
      # Calculated the same as apache, not sure how well the works on win32
      etag = Const::ETAG_FORMAT % [mtime.to_i, stat.size, stat.ino]

      modified_since = request.params[Const::HTTP_IF_MODIFIED_SINCE]
      none_match = request.params[Const::HTTP_IF_NONE_MATCH]

      # test to see if this is a conditional request, and test if
      # the response would be identical to the last response
      same_response = case
                      when modified_since && !last_response_time = Time.httpdate(modified_since) rescue nil : false
                      when modified_since && last_response_time > Time.now                                  : false
                      when modified_since && mtime > last_response_time                                     : false
                      when none_match     && none_match == '*'                                              : false
                      when none_match     && !none_match.strip.split(/\s*,\s*/).include?(etag)              : false
                      else modified_since || none_match  # validation successful if we get this far and at least one of the header exists
                      end

      header = response.header
      header[Const::ETAG] = etag

      if same_response
        response.start(304) {}
      else
        
        # First we setup the headers and status then we do a very fast send on the socket directly
        
        # Support custom responses except 404, which is the default. A little awkward. 
        response.status = 200 if response.status == 404        
        header[Const::LAST_MODIFIED] = mtime.httpdate

        # Set the mime type from our map based on the ending
        dot_at = req_path.rindex('.')
        if dot_at
          header[Const::CONTENT_TYPE] = MIME_TYPES[req_path[dot_at .. -1]] || @default_content_type
        else
          header[Const::CONTENT_TYPE] = @default_content_type
        end

        # send a status with out content length
        response.send_status(stat.size)
        response.send_header

        if not header_only
          response.send_file(req_path, stat.size < Const::CHUNK_SIZE * 2)
        end
      end
    end

    # Process the request to either serve a file or a directory listing
    # if allowed (based on the listing_allowed parameter to the constructor).
    def process(request, response)
      req_method = request.params[Const::REQUEST_METHOD] || Const::GET
      req_path = can_serve request.params[Const::PATH_INFO]
      if not req_path
        # not found, return a 404
        response.start(404) do |head,out|
          out << "File not found"
        end
      else
        begin
          if File.directory? req_path
            send_dir_listing(request.params[Const::REQUEST_URI], req_path, response)
          elsif req_method == Const::HEAD
            send_file(req_path, request, response, true)
          elsif req_method == Const::GET
            send_file(req_path, request, response, false)
          else
            response.start(403) {|head,out| out.write(ONLY_HEAD_GET) }
          end
        rescue => details
          STDERR.puts "Error sending file #{req_path}: #{details}"
        end
      end
    end

    # There is a small number of default mime types for extensions, but
    # this lets you add any others you'll need when serving content.
    def DirHandler::add_mime_type(extension, type)
      MIME_TYPES[extension] = type
    end

  end


  # When added to a config script (-S in mongrel_rails) it will
  # look at the client's allowed response types and then gzip 
  # compress anything that is going out.
  #
  # Valid option is :always_deflate => false which tells the handler to
  # deflate everything even if the client can't handle it.
  class DeflateFilter < HttpHandler
    include Zlib
    HTTP_ACCEPT_ENCODING = "HTTP_ACCEPT_ENCODING" 

    def initialize(ops={})
      @options = ops
      @always_deflate = ops[:always_deflate] || false
    end

    def process(request, response)
      accepts = request.params[HTTP_ACCEPT_ENCODING]
      # only process if they support compression
      if @always_deflate or (accepts and (accepts.include? "deflate" and not response.body_sent))
        response.header["Content-Encoding"] = "deflate"
        response.body = deflate(response.body)
      end
    end

    private
      def deflate(stream)
        deflater = Deflate.new(
          DEFAULT_COMPRESSION,
          # drop the zlib header which causes both Safari and IE to choke
          -MAX_WBITS, 
          DEF_MEM_LEVEL,
          DEFAULT_STRATEGY)

        stream.rewind
        gzout = StringIO.new(deflater.deflate(stream.read, FINISH))
        stream.close
        gzout.rewind
        gzout
      end
  end


  # Implements a few basic statistics for a particular URI.  Register it anywhere
  # you want in the request chain and it'll quickly gather some numbers for you
  # to analyze.  It is pretty fast, but don't put it out in production.
  #
  # You should pass the filter to StatusHandler as StatusHandler.new(:stats_filter => stats).
  # This lets you then hit the status URI you want and get these stats from a browser.
  #
  # StatisticsFilter takes an option of :sample_rate.  This is a number that's passed to
  # rand and if that number gets hit then a sample is taken.  This helps reduce the load
  # and keeps the statistics valid (since sampling is a part of how they work).
  #
  # The exception to :sample_rate is that inter-request time is sampled on every request.
  # If this wasn't done then it wouldn't be accurate as a measure of time between requests.
  class StatisticsFilter < HttpHandler
    attr_reader :stats

    def initialize(ops={})
      @sample_rate = ops[:sample_rate] || 300

      @processors = Mongrel::Stats.new("processors")
      @reqsize = Mongrel::Stats.new("request Kb")
      @headcount = Mongrel::Stats.new("req param count")
      @respsize = Mongrel::Stats.new("response Kb")
      @interreq = Mongrel::Stats.new("inter-request time")
    end


    def process(request, response)
      if rand(@sample_rate)+1 == @sample_rate
        @processors.sample(listener.workers.list.length)
        @headcount.sample(request.params.length)
        @reqsize.sample(request.body.length / 1024.0)
        @respsize.sample((response.body.length + response.header.out.length) / 1024.0)
      end
      @interreq.tick
    end

    def dump
      "#{@processors.to_s}\n#{@reqsize.to_s}\n#{@headcount.to_s}\n#{@respsize.to_s}\n#{@interreq.to_s}"
    end
  end


  # The :stats_filter is basically any configured stats filter that you've added to this same
  # URI.  This lets the status handler print out statistics on how Mongrel is doing.
  class StatusHandler < HttpHandler
    def initialize(ops={})
      @stats = ops[:stats_filter]
    end

    def table(title, rows)
      results = "<table border=\"1\"><tr><th colspan=\"#{rows[0].length}\">#{title}</th></tr>"
      rows.each do |cols|
        results << "<tr>"
        cols.each {|col| results << "<td>#{col}</td>" }
        results << "</tr>"
      end
      results + "</table>"
    end

    def describe_listener
      results = ""
      results << "<h1>Listener #{listener.host}:#{listener.port}</h1>"
      results << table("settings", [
                       ["host",listener.host],
                       ["port",listener.port],
                       ["throttle",listener.throttle],
                       ["timeout",listener.timeout],
                       ["workers max",listener.num_processors],
      ])

      if @stats
        results << "<h2>Statistics</h2><p>N means the number of samples, pay attention to MEAN, SD, MIN and MAX."
        results << "<pre>#{@stats.dump}</pre>"
      end

      results << "<h2>Registered Handlers</h2>"
      handler_map = listener.classifier.handler_map
      results << table("handlers", handler_map.map {|uri,handlers| 
        [uri, 
            "<pre>" + 
            handlers.map {|h| h.class.to_s }.join("\n") + 
            "</pre>"
        ]
      })

      results
    end

    def process(request, response)
      response.start do |head,out|
        out.write <<-END
        <html><body><title>Mongrel Server Status</title>
        #{describe_listener}
        </body></html>
        END
      end
    end
  end

  # This handler allows you to redirect one url to another.
  # You can use it like String#gsub, where the string is the REQUEST_URI.
  # REQUEST_URI is the full path with GET parameters.
  #
  # Eg. /test/something?help=true&disclaimer=false
  #
  # == Examples
  #
  #   h = Mongrel::HttpServer.new('0.0.0.0')
  #   h.register '/test', Mongrel::RedirectHandler.new('/to/there') # simple
  #   h.register '/to',   Mongrel::RedirectHandler.new(/t/, 'w') # regexp
  #   # and with a block
  #   h.register '/hey',  Mongrel::RedirectHandler.new(/(\w+)/) { |match| ... }
  # 
  class RedirectHandler < Mongrel::HttpHandler
    # You set the rewrite rules when building the object.
    #
    # pattern            => What to look for or replacement if used alone
    #
    # replacement, block => One of them is used to replace the found text

    def initialize(pattern, replacement = nil, &block)
      unless replacement or block
        @pattern, @replacement = nil, pattern
      else
        @pattern, @replacement, @block = pattern, replacement, block
      end
    end

    # Process the request and return a redirect response
    def process(request, response)
      unless @pattern
        response.socket.write(Mongrel::Const::REDIRECT % @replacement)
      else
        if @block
          new_path = request.params['REQUEST_URI'].gsub(@pattern, &@block)
        else
          new_path = request.params['REQUEST_URI'].gsub(@pattern, @replacement)
        end
        response.socket.write(Mongrel::Const::REDIRECT % new_path)
      end
    end
  end
end
