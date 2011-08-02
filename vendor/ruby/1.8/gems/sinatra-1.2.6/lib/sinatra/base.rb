require 'thread'
require 'time'
require 'uri'
require 'rack'
require 'rack/builder'
require 'sinatra/showexceptions'
require 'tilt'

module Sinatra
  VERSION = '1.2.6'

  # The request object. See Rack::Request for more info:
  # http://rack.rubyforge.org/doc/classes/Rack/Request.html
  class Request < Rack::Request
    # Returns an array of acceptable media types for the response
    def accept
      @env['sinatra.accept'] ||= begin
        entries = @env['HTTP_ACCEPT'].to_s.split(',')
        entries.map { |e| accept_entry(e) }.sort_by(&:last).map(&:first)
      end
    end

    def preferred_type(*types)
      return accept.first if types.empty?
      types.flatten!
      accept.detect do |pattern|
        type = types.detect { |t| File.fnmatch(pattern, t) }
        return type if type
      end
    end

    if Rack.release <= "1.2"
      # Whether or not the web server (or a reverse proxy in front of it) is
      # using SSL to communicate with the client.
      def secure?
        @env['HTTPS'] == 'on' or
        @env['HTTP_X_FORWARDED_PROTO'] == 'https' or
        @env['rack.url_scheme'] == 'https'
      end
    else
      alias secure? ssl?
    end

    def forwarded?
      @env.include? "HTTP_X_FORWARDED_HOST"
    end

    def route
      @route ||= Rack::Utils.unescape(path_info)
    end

    def path_info=(value)
      @route = nil
      super
    end

    private

    def accept_entry(entry)
      type, *options = entry.gsub(/\s/, '').split(';')
      quality = 0 # we sort smalles first
      options.delete_if { |e| quality = 1 - e[2..-1].to_f if e =~ /^q=/ }
      [type, [quality, type.count('*'), 1 - options.size]]
    end
  end

  # The response object. See Rack::Response and Rack::ResponseHelpers for
  # more info:
  # http://rack.rubyforge.org/doc/classes/Rack/Response.html
  # http://rack.rubyforge.org/doc/classes/Rack/Response/Helpers.html
  class Response < Rack::Response
    def finish
      @body = block if block_given?
      if [204, 304].include?(status.to_i)
        header.delete "Content-Type"
        [status.to_i, header.to_hash, []]
      else
        body = @body || []
        body = [body] if body.respond_to? :to_str
        if body.respond_to?(:to_ary)
          header["Content-Length"] = body.to_ary.
            inject(0) { |len, part| len + Rack::Utils.bytesize(part) }.to_s
        end
        [status.to_i, header.to_hash, body]
      end
    end
  end

  class NotFound < NameError #:nodoc:
    def code ; 404 ; end
  end

  # Methods available to routes, before/after filters, and views.
  module Helpers
    # Set or retrieve the response status code.
    def status(value=nil)
      response.status = value if value
      response.status
    end

    # Set or retrieve the response body. When a block is given,
    # evaluation is deferred until the body is read with #each.
    def body(value=nil, &block)
      if block_given?
        def block.each; yield(call) end
        response.body = block
      elsif value
        response.body = value
      else
        response.body
      end
    end

    # Halt processing and redirect to the URI provided.
    def redirect(uri, *args)
      status 302

      # According to RFC 2616 section 14.30, "the field value consists of a
      # single absolute URI"
      response['Location'] = uri(uri, settings.absolute_redirects?, settings.prefixed_redirects?)
      halt(*args)
    end

    # Generates the absolute URI for a given path in the app.
    # Takes Rack routers and reverse proxies into account.
    def uri(addr = nil, absolute = true, add_script_name = true)
      return addr if addr =~ /\A[A-z][A-z0-9\+\.\-]*:/
      uri = [host = ""]
      if absolute
        host << 'http'
        host << 's' if request.secure?
        host << "://"
        if request.forwarded? or request.port != (request.secure? ? 443 : 80)
          host << request.host_with_port
        else
          host << request.host
        end
      end
      uri << request.script_name.to_s if add_script_name
      uri << (addr ? addr : request.path_info).to_s
      File.join uri
    end

    alias url uri
    alias to uri

    # Halt processing and return the error status provided.
    def error(code, body=nil)
      code, body    = 500, code.to_str if code.respond_to? :to_str
      response.body = body unless body.nil?
      halt code
    end

    # Halt processing and return a 404 Not Found.
    def not_found(body=nil)
      error 404, body
    end

    # Set multiple response headers with Hash.
    def headers(hash=nil)
      response.headers.merge! hash if hash
      response.headers
    end

    # Access the underlying Rack session.
    def session
      request.session
    end

    # Look up a media type by file extension in Rack's mime registry.
    def mime_type(type)
      Base.mime_type(type)
    end

    # Set the Content-Type of the response body given a media type or file
    # extension.
    def content_type(type = nil, params={})
      return response['Content-Type'] unless type
      default = params.delete :default
      mime_type = mime_type(type) || default
      fail "Unknown media type: %p" % type if mime_type.nil?
      mime_type = mime_type.dup
      unless params.include? :charset or settings.add_charset.all? { |p| not p === mime_type }
        params[:charset] = params.delete('charset') || settings.default_encoding
      end
      params.delete :charset if mime_type.include? 'charset'
      unless params.empty?
        mime_type << (mime_type.include?(';') ? ', ' : ';')
        mime_type << params.map { |kv| kv.join('=') }.join(', ')
      end
      response['Content-Type'] = mime_type
    end

    # Set the Content-Disposition to "attachment" with the specified filename,
    # instructing the user agents to prompt to save.
    def attachment(filename=nil)
      response['Content-Disposition'] = 'attachment'
      if filename
        params = '; filename="%s"' % File.basename(filename)
        response['Content-Disposition'] << params
      end
    end

    # Use the contents of the file at +path+ as the response body.
    def send_file(path, opts={})
      stat = File.stat(path)
      last_modified(opts[:last_modified] || stat.mtime)

      if opts[:type] or not response['Content-Type']
        content_type opts[:type] || File.extname(path), :default => 'application/octet-stream'
      end

      if opts[:disposition] == 'attachment' || opts[:filename]
        attachment opts[:filename] || path
      elsif opts[:disposition] == 'inline'
        response['Content-Disposition'] = 'inline'
      end

      file_length = opts[:length] || stat.size
      sf = StaticFile.open(path, 'rb')
      if ! sf.parse_ranges(env, file_length)
        response['Content-Range'] = "bytes */#{file_length}"
        halt 416
      elsif r=sf.range
        response['Content-Range'] = "bytes #{r.begin}-#{r.end}/#{file_length}"
        response['Content-Length'] = (r.end - r.begin + 1).to_s
        halt 206, sf
      else
        response['Content-Length'] ||= file_length.to_s
        halt sf
      end
    rescue Errno::ENOENT
      not_found
    end

    # Rack response body used to deliver static files. The file contents are
    # generated iteratively in 8K chunks.
    class StaticFile < ::File #:nodoc:
      alias_method :to_path, :path

      attr_accessor :range  # a Range or nil

      # Checks for byte-ranges in the request and sets self.range appropriately.
      # Returns false if the ranges are unsatisfiable and the request should return 416.
      def parse_ranges(env, size)
        #r = Rack::Utils::byte_ranges(env, size)  # TODO: not available yet in released Rack
        r = byte_ranges(env, size)
        return false if r == []  # Unsatisfiable; report error
        @range = r[0] if r && r.length == 1  # Ignore multiple-range requests for now
        return true
      end

      # TODO: Copied from the new method Rack::Utils::byte_ranges; this method can be removed once
      # a version of Rack with that method is released and Sinatra can depend on it.
      def byte_ranges(env, size)
        # See <http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.35>
        http_range = env['HTTP_RANGE']
        return nil unless http_range
        ranges = []
        http_range.split(/,\s*/).each do |range_spec|
          matches = range_spec.match(/bytes=(\d*)-(\d*)/)
          return nil  unless matches
          r0,r1 = matches[1], matches[2]
          if r0.empty?
            return nil  if r1.empty?
            # suffix-byte-range-spec, represents trailing suffix of file
            r0 = [size - r1.to_i, 0].max
            r1 = size - 1
          else
            r0 = r0.to_i
            if r1.empty?
              r1 = size - 1
            else
              r1 = r1.to_i
              return nil  if r1 < r0  # backwards range is syntactically invalid
              r1 = size-1  if r1 >= size
            end
          end
          ranges << (r0..r1)  if r0 <= r1
        end
        ranges
      end

      CHUNK_SIZE = 8192

      def each
        if @range
          self.pos = @range.begin
          length = @range.end - @range.begin + 1
          while length > 0 && (buf = read([CHUNK_SIZE,length].min))
            yield buf
            length -= buf.length
          end
        else
          rewind
          while buf = read(CHUNK_SIZE)
            yield buf
          end
        end
      end
    end

    # Specify response freshness policy for HTTP caches (Cache-Control header).
    # Any number of non-value directives (:public, :private, :no_cache,
    # :no_store, :must_revalidate, :proxy_revalidate) may be passed along with
    # a Hash of value directives (:max_age, :min_stale, :s_max_age).
    #
    #   cache_control :public, :must_revalidate, :max_age => 60
    #   => Cache-Control: public, must-revalidate, max-age=60
    #
    # See RFC 2616 / 14.9 for more on standard cache control directives:
    # http://tools.ietf.org/html/rfc2616#section-14.9.1
    def cache_control(*values)
      if values.last.kind_of?(Hash)
        hash = values.pop
        hash.reject! { |k,v| v == false }
        hash.reject! { |k,v| values << k if v == true }
      else
        hash = {}
      end

      values = values.map { |value| value.to_s.tr('_','-') }
      hash.each do |key, value|
        key = key.to_s.tr('_', '-')
        value = value.to_i if key == "max-age"
        values << [key, value].join('=')
      end

      response['Cache-Control'] = values.join(', ') if values.any?
    end

    # Set the Expires header and Cache-Control/max-age directive. Amount
    # can be an integer number of seconds in the future or a Time object
    # indicating when the response should be considered "stale". The remaining
    # "values" arguments are passed to the #cache_control helper:
    #
    #   expires 500, :public, :must_revalidate
    #   => Cache-Control: public, must-revalidate, max-age=60
    #   => Expires: Mon, 08 Jun 2009 08:50:17 GMT
    #
    def expires(amount, *values)
      values << {} unless values.last.kind_of?(Hash)

      if amount.is_a? Integer
        time    = Time.now + amount.to_i
        max_age = amount
      else
        time    = time_for amount
        max_age = time - Time.now
      end

      values.last.merge!(:max_age => max_age)
      cache_control(*values)

      response['Expires'] = time.httpdate
    end

    # Set the last modified time of the resource (HTTP 'Last-Modified' header)
    # and halt if conditional GET matches. The +time+ argument is a Time,
    # DateTime, or other object that responds to +to_time+.
    #
    # When the current request includes an 'If-Modified-Since' header that is
    # equal or later than the time specified, execution is immediately halted
    # with a '304 Not Modified' response.
    def last_modified(time)
      return unless time
      time = time_for time
      response['Last-Modified'] = time.httpdate
      # compare based on seconds since epoch
      halt 304 if Time.httpdate(env['HTTP_IF_MODIFIED_SINCE']).to_i >= time.to_i
    rescue ArgumentError
    end

    # Set the response entity tag (HTTP 'ETag' header) and halt if conditional
    # GET matches. The +value+ argument is an identifier that uniquely
    # identifies the current version of the resource. The +kind+ argument
    # indicates whether the etag should be used as a :strong (default) or :weak
    # cache validator.
    #
    # When the current request includes an 'If-None-Match' header with a
    # matching etag, execution is immediately halted. If the request method is
    # GET or HEAD, a '304 Not Modified' response is sent.
    def etag(value, kind=:strong)
      raise TypeError, ":strong or :weak expected" if ![:strong,:weak].include?(kind)
      value = '"%s"' % value
      value = 'W/' + value if kind == :weak
      response['ETag'] = value

      # Conditional GET check
      if etags = env['HTTP_IF_NONE_MATCH']
        etags = etags.split(/\s*,\s*/)
        halt 304 if etags.include?(value) || etags.include?('*')
      end
    end

    # Sugar for redirect (example:  redirect back)
    def back
      request.referer
    end

    private

    # Ruby 1.8 has no #to_time method.
    # This can be removed and calls to it replaced with to_time,
    # if 1.8 support is dropped.
    def time_for(value)
      if value.respond_to? :to_time
        value.to_time
      elsif value.is_a? Time
        value
      elsif value.respond_to? :new_offset
        # DateTime#to_time does the same on 1.9
        d = value.new_offset 0
        t = Time.utc d.year, d.mon, d.mday, d.hour, d.min, d.sec + d.sec_fraction
        t.getlocal
      elsif value.respond_to? :mday
        # Date#to_time does the same on 1.9
        Time.local(value.year, value.mon, value.mday)
      elsif value.is_a? Numeric
        Time.at value
      else
        Time.parse value.to_s
      end
    rescue ArgumentError => boom
      raise boom
    rescue Exception
      raise ArgumentError, "unable to convert #{value.inspect} to a Time object"
    end
  end

  # Template rendering methods. Each method takes the name of a template
  # to render as a Symbol and returns a String with the rendered output,
  # as well as an optional hash with additional options.
  #
  # `template` is either the name or path of the template as symbol
  # (Use `:'subdir/myview'` for views in subdirectories), or a string
  # that will be rendered.
  #
  # Possible options are:
  #   :content_type   The content type to use, same arguments as content_type.
  #   :layout         If set to false, no layout is rendered, otherwise
  #                   the specified layout is used (Ignored for `sass` and `less`)
  #   :layout_engine  Engine to use for rendering the layout.
  #   :locals         A hash with local variables that should be available
  #                   in the template
  #   :scope          If set, template is evaluate with the binding of the given
  #                   object rather than the application instance.
  #   :views          Views directory to use.
  module Templates
    module ContentTyped
      attr_accessor :content_type
    end

    def erb(template, options={}, locals={})
      render :erb, template, options, locals
    end

    def erubis(template, options={}, locals={})
      render :erubis, template, options, locals
    end

    def haml(template, options={}, locals={})
      render :haml, template, options, locals
    end

    def sass(template, options={}, locals={})
      options.merge! :layout => false, :default_content_type => :css
      render :sass, template, options, locals
    end

    def scss(template, options={}, locals={})
      options.merge! :layout => false, :default_content_type => :css
      render :scss, template, options, locals
    end

    def less(template, options={}, locals={})
      options.merge! :layout => false, :default_content_type => :css
      render :less, template, options, locals
    end

    def builder(template=nil, options={}, locals={}, &block)
      options[:default_content_type] = :xml
      render_ruby(:builder, template, options, locals, &block)
    end

    def liquid(template, options={}, locals={})
      render :liquid, template, options, locals
    end

    def markdown(template, options={}, locals={})
      render :markdown, template, options, locals
    end

    def textile(template, options={}, locals={})
      render :textile, template, options, locals
    end

    def rdoc(template, options={}, locals={})
      render :rdoc, template, options, locals
    end

    def radius(template, options={}, locals={})
      render :radius, template, options, locals
    end

    def markaby(template=nil, options={}, locals={}, &block)
      render_ruby(:mab, template, options, locals, &block)
    end

    def coffee(template, options={}, locals={})
      options.merge! :layout => false, :default_content_type => :js
      render :coffee, template, options, locals
    end

    def nokogiri(template=nil, options={}, locals={}, &block)
      options[:default_content_type] = :xml
      render_ruby(:nokogiri, template, options, locals, &block)
    end

    def slim(template, options={}, locals={})
      render :slim, template, options, locals
    end

    # Calls the given block for every possible template file in views,
    # named name.ext, where ext is registered on engine.
    def find_template(views, name, engine)
      yield ::File.join(views, "#{name}.#{@preferred_extension}")
      Tilt.mappings.each do |ext, engines|
        next unless ext != @preferred_extension and Array(engines).include? engine
        yield ::File.join(views, "#{name}.#{ext}")
      end
    end

  private
    # logic shared between builder and nokogiri
    def render_ruby(engine, template, options={}, locals={}, &block)
      options, template = template, nil if template.is_a?(Hash)
      template = Proc.new { block } if template.nil?
      render engine, template, options, locals
    end

    def render(engine, data, options={}, locals={}, &block)
      # merge app-level options
      options = settings.send(engine).merge(options) if settings.respond_to?(engine)
      options[:outvar]           ||= '@_out_buf'
      options[:default_encoding] ||= settings.default_encoding

      # extract generic options
      locals          = options.delete(:locals) || locals         || {}
      views           = options.delete(:views)  || settings.views || "./views"
      @default_layout = :layout if @default_layout.nil?
      layout          = options.delete(:layout)
      eat_errors      = layout.nil?
      layout          = @default_layout if layout.nil? or layout == true
      content_type    = options.delete(:content_type)  || options.delete(:default_content_type)
      layout_engine   = options.delete(:layout_engine) || engine
      scope           = options.delete(:scope)         || self

      # compile and render template
      layout_was      = @default_layout
      @default_layout = false
      template        = compile_template(engine, data, options, views)
      output          = template.render(scope, locals, &block)
      @default_layout = layout_was

      # render layout
      if layout
        options = options.merge(:views => views, :layout => false, :eat_errors => eat_errors, :scope => scope)
        catch(:layout_missing) { return render(layout_engine, layout, options, locals) { output } }
      end

      output.extend(ContentTyped).content_type = content_type if content_type
      output
    end

    def compile_template(engine, data, options, views)
      eat_errors = options.delete :eat_errors
      template_cache.fetch engine, data, options do
        template = Tilt[engine]
        raise "Template engine not found: #{engine}" if template.nil?

        case
        when data.is_a?(Symbol)
          body, path, line = settings.templates[data]
          if body
            body = body.call if body.respond_to?(:call)
            template.new(path, line.to_i, options) { body }
          else
            found = false
            @preferred_extension = engine.to_s
            find_template(views, data, template) do |file|
              path ||= file # keep the initial path rather than the last one
              if found = File.exists?(file)
                path = file
                break
              end
            end
            throw :layout_missing if eat_errors and not found
            template.new(path, 1, options)
          end
        when data.is_a?(Proc) || data.is_a?(String)
          body = data.is_a?(String) ? Proc.new { data } : data
          path, line = settings.caller_locations.first
          template.new(path, line.to_i, options, &body)
        else
          raise ArgumentError
        end
      end
    end
  end

  # Base class for all Sinatra applications and middleware.
  class Base
    include Rack::Utils
    include Helpers
    include Templates

    attr_accessor :app
    attr_reader   :template_cache

    def initialize(app=nil)
      @app = app
      @template_cache = Tilt::Cache.new
      yield self if block_given?
    end

    # Rack call interface.
    def call(env)
      dup.call!(env)
    end

    attr_accessor :env, :request, :response, :params

    def call!(env) # :nodoc:
      @env      = env
      @request  = Request.new(env)
      @response = Response.new
      @params   = indifferent_params(@request.params)
      template_cache.clear if settings.reload_templates
      force_encoding(@request.route)
      force_encoding(@params)

      @response['Content-Type'] = nil
      invoke { dispatch! }
      invoke { error_block!(response.status) }
      unless @response['Content-Type']
        if body.respond_to?(:to_ary) and body.first.respond_to? :content_type
          content_type body.first.content_type
        else
          content_type :html
        end
      end

      @response.finish
    end

    # Access settings defined with Base.set.
    def self.settings
      self
    end

    # Access settings defined with Base.set.
    def settings
      self.class.settings
    end

    alias_method :options, :settings
    class << self
      alias_method :options, :settings
    end

    # Exit the current block, halts any further processing
    # of the request, and returns the specified response.
    def halt(*response)
      response = response.first if response.length == 1
      throw :halt, response
    end

    # Pass control to the next matching route.
    # If there are no more matching routes, Sinatra will
    # return a 404 response.
    def pass(&block)
      throw :pass, block
    end

    # Forward the request to the downstream app -- middleware only.
    def forward
      fail "downstream app not set" unless @app.respond_to? :call
      status, headers, body = @app.call env
      @response.status = status
      @response.body = body
      @response.headers.merge! headers
      nil
    end

  private
    # Run filters defined on the class and all superclasses.
    def filter!(type, base = settings)
      filter! type, base.superclass if base.superclass.respond_to?(:filters)
      base.filters[type].each { |block| instance_eval(&block) }
    end

    # Run routes defined on the class and all superclasses.
    def route!(base = settings, pass_block=nil)
      if routes = base.routes[@request.request_method]
        routes.each do |pattern, keys, conditions, block|
          pass_block = process_route(pattern, keys, conditions) do
            route_eval(&block)
          end
        end
      end

      # Run routes defined in superclass.
      if base.superclass.respond_to?(:routes)
        return route!(base.superclass, pass_block)
      end

      route_eval(&pass_block) if pass_block
      route_missing
    end

    # Run a route block and throw :halt with the result.
    def route_eval(&block)
      throw :halt, instance_eval(&block)
    end

    # If the current request matches pattern and conditions, fill params
    # with keys and call the given block.
    # Revert params afterwards.
    #
    # Returns pass block.
    def process_route(pattern, keys, conditions)
      @original_params ||= @params
      route = @request.route
      route = '/' if route.empty? and not settings.empty_path_info?
      if match = pattern.match(route)
        values = match.captures.to_a
        params =
          if keys.any?
            keys.zip(values).inject({}) do |hash,(k,v)|
              if k == 'splat'
                (hash[k] ||= []) << v
              else
                hash[k] = v
              end
              hash
            end
          elsif values.any?
            {'captures' => values}
          else
            {}
          end
        @params = @original_params.merge(params)
        @block_params = values
        catch(:pass) do
          conditions.each { |cond|
            throw :pass if instance_eval(&cond) == false }
          yield
        end
      end
    ensure
      @params = @original_params
    end

    # No matching route was found or all routes passed. The default
    # implementation is to forward the request downstream when running
    # as middleware (@app is non-nil); when no downstream app is set, raise
    # a NotFound exception. Subclasses can override this method to perform
    # custom route miss logic.
    def route_missing
      if @app
        forward
      else
        raise NotFound
      end
    end

    # Attempt to serve static files from public directory. Throws :halt when
    # a matching file is found, returns nil otherwise.
    def static!
      return if (public_dir = settings.public).nil?
      public_dir = File.expand_path(public_dir)

      path = File.expand_path(public_dir + unescape(request.path_info))
      return if path[0, public_dir.length] != public_dir
      return unless File.file?(path)

      env['sinatra.static_file'] = path
      send_file path, :disposition => nil
    end

    # Enable string or symbol key access to the nested params hash.
    def indifferent_params(params)
      params = indifferent_hash.merge(params)
      params.each do |key, value|
        next unless value.is_a?(Hash)
        params[key] = indifferent_params(value)
      end
    end

    # Creates a Hash with indifferent access.
    def indifferent_hash
      Hash.new {|hash,key| hash[key.to_s] if Symbol === key }
    end

    # Run the block with 'throw :halt' support and apply result to the response.
    def invoke(&block)
      res = catch(:halt) { instance_eval(&block) }
      return if res.nil?

      case
      when res.respond_to?(:to_str)
        @response.body = [res]
      when res.respond_to?(:to_ary)
        res = res.to_ary
        if Fixnum === res.first
          if res.length == 3
            @response.status, headers, body = res
            @response.body = body if body
            headers.each { |k, v| @response.headers[k] = v } if headers
          elsif res.length == 2
            @response.status = res.first
            @response.body   = res.last
          else
            raise TypeError, "#{res.inspect} not supported"
          end
        else
          @response.body = res
        end
      when res.respond_to?(:each)
        @response.body = res
      when (100..599) === res
        @response.status = res
      end

      res
    end

    # Dispatch a request with error handling.
    def dispatch!
      static! if settings.static? && (request.get? || request.head?)
      filter! :before
      route!
    rescue NotFound => boom
      handle_not_found!(boom)
    rescue ::Exception => boom
      handle_exception!(boom)
    ensure
      filter! :after unless env['sinatra.static_file']
    end

    # Special treatment for 404s in order to play nice with cascades.
    def handle_not_found!(boom)
      @env['sinatra.error']          = boom
      @response.status               = 404
      @response.headers['X-Cascade'] = 'pass'
      @response.body                 = ['<h1>Not Found</h1>']
      error_block! boom.class, NotFound
    end

    # Error handling during requests.
    def handle_exception!(boom)
      @env['sinatra.error'] = boom

      dump_errors!(boom) if settings.dump_errors?
      raise boom if settings.show_exceptions? and settings.show_exceptions != :after_handler

      @response.status = 500
      if res = error_block!(boom.class)
        res
      elsif settings.raise_errors?
        raise boom
      else
        error_block!(Exception)
      end
    end

    # Find an custom error block for the key(s) specified.
    def error_block!(*keys)
      keys.each do |key|
        base = settings
        while base.respond_to?(:errors)
          if block = base.errors[key]
            # found a handler, eval and return result
            return instance_eval(&block)
          else
            base = base.superclass
          end
        end
      end
      raise boom if settings.show_exceptions? and keys == Exception
      nil
    end

    def dump_errors!(boom)
      msg = ["#{boom.class} - #{boom.message}:",
        *boom.backtrace].join("\n ")
      @env['rack.errors'].puts(msg)
    end

    class << self
      attr_reader :routes, :filters, :templates, :errors

      # Removes all routes, filters, middleware and extension hooks from the
      # current class (not routes/filters/... defined by its superclass).
      def reset!
        @conditions     = []
        @routes         = {}
        @filters        = {:before => [], :after => []}
        @errors         = {}
        @middleware     = []
        @prototype      = nil
        @extensions     = []

        if superclass.respond_to?(:templates)
          @templates = Hash.new { |hash,key| superclass.templates[key] }
        else
          @templates = {}
        end
      end

      # Extension modules registered on this class and all superclasses.
      def extensions
        if superclass.respond_to?(:extensions)
          (@extensions + superclass.extensions).uniq
        else
          @extensions
        end
      end

      # Middleware used in this class and all superclasses.
      def middleware
        if superclass.respond_to?(:middleware)
          superclass.middleware + @middleware
        else
          @middleware
        end
      end

      # Sets an option to the given value.  If the value is a proc,
      # the proc will be called every time the option is accessed.
      def set(option, value = (not_set = true), &block)
        raise ArgumentError if block and !not_set
        value = block if block
        if value.kind_of?(Proc)
          metadef(option, &value)
          metadef("#{option}?") { !!__send__(option) }
          metadef("#{option}=") { |val| metadef(option, &Proc.new{val}) }
        elsif not_set
          raise ArgumentError unless option.respond_to?(:each)
          option.each { |k,v| set(k, v) }
        elsif respond_to?("#{option}=")
          __send__ "#{option}=", value
        else
          set option, Proc.new{value}
        end
        self
      end

      # Same as calling `set :option, true` for each of the given options.
      def enable(*opts)
        opts.each { |key| set(key, true) }
      end

      # Same as calling `set :option, false` for each of the given options.
      def disable(*opts)
        opts.each { |key| set(key, false) }
      end

      # Define a custom error handler. Optionally takes either an Exception
      # class, or an HTTP status code to specify which errors should be
      # handled.
      def error(codes=Exception, &block)
        Array(codes).each { |code| @errors[code] = block }
      end

      # Sugar for `error(404) { ... }`
      def not_found(&block)
        error 404, &block
      end

      # Define a named template. The block must return the template source.
      def template(name, &block)
        filename, line = caller_locations.first
        templates[name] = [block, filename, line.to_i]
      end

      # Define the layout template. The block must return the template source.
      def layout(name=:layout, &block)
        template name, &block
      end

      # Load embeded templates from the file; uses the caller's __FILE__
      # when no file is specified.
      def inline_templates=(file=nil)
        file = (file.nil? || file == true) ? (caller_files.first || File.expand_path($0)) : file

        begin
          io = ::IO.respond_to?(:binread) ? ::IO.binread(file) : ::IO.read(file)
          app, data = io.gsub("\r\n", "\n").split(/^__END__$/, 2)
        rescue Errno::ENOENT
          app, data = nil
        end

        if data
          if app and app =~ /([^\n]*\n)?#[^\n]*coding: *(\S+)/m
            encoding = $2
          else
            encoding = settings.default_encoding
          end
          lines = app.count("\n") + 1
          template = nil
          force_encoding data, encoding
          data.each_line do |line|
            lines += 1
            if line =~ /^@@\s*(.*\S)\s*$/
              template = force_encoding('', encoding)
              templates[$1.to_sym] = [template, file, lines]
            elsif template
              template << line
            end
          end
        end
      end

      # Lookup or register a mime type in Rack's mime registry.
      def mime_type(type, value=nil)
        return type if type.nil? || type.to_s.include?('/')
        type = ".#{type}" unless type.to_s[0] == ?.
        return Rack::Mime.mime_type(type, nil) unless value
        Rack::Mime::MIME_TYPES[type] = value
      end

      # provides all mime types matching type, including deprecated types:
      #   mime_types :html # => ['text/html']
      #   mime_types :js   # => ['application/javascript', 'text/javascript']
      def mime_types(type)
        type = mime_type type
        type =~ /^application\/(xml|javascript)$/ ? [type, "text/#$1"] : [type]
      end

      # Define a before filter; runs before all requests within the same
      # context as route handlers and may access/modify the request and
      # response.
      def before(path = nil, options = {}, &block)
        add_filter(:before, path, options, &block)
      end

      # Define an after filter; runs after all requests within the same
      # context as route handlers and may access/modify the request and
      # response.
      def after(path = nil, options = {}, &block)
        add_filter(:after, path, options, &block)
      end

      # add a filter
      def add_filter(type, path = nil, options = {}, &block)
        return filters[type] << block unless path
        path, options = //, path if path.respond_to?(:each_pair)
        block, *arguments = compile!(type, path, block, options)
        add_filter(type) do
          process_route(*arguments) { instance_eval(&block) }
        end
      end

      # Add a route condition. The route is considered non-matching when the
      # block returns false.
      def condition(&block)
        @conditions << block
      end

   private
      # Condition for matching host name. Parameter might be String or Regexp.
      def host_name(pattern)
        condition { pattern === request.host }
      end

      # Condition for matching user agent. Parameter should be Regexp.
      # Will set params[:agent].
      def user_agent(pattern)
        condition do
          if request.user_agent.to_s =~ pattern
            @params[:agent] = $~[1..-1]
            true
          else
            false
          end
        end
      end
      alias_method :agent, :user_agent

      # Condition for matching mimetypes. Accepts file extensions.
      def provides(*types)
        types.map! { |t| mime_types(t) }
        types.flatten!
        condition do
          if type = request.preferred_type(types)
            content_type(type)
            true
          else
            false
          end
        end
      end

    public
      # Defining a `GET` handler also automatically defines
      # a `HEAD` handler.
      def get(path, opts={}, &block)
        conditions = @conditions.dup
        route('GET', path, opts, &block)

        @conditions = conditions
        route('HEAD', path, opts, &block)
      end

      def put(path, opts={}, &bk)     route 'PUT',     path, opts, &bk end
      def post(path, opts={}, &bk)    route 'POST',    path, opts, &bk end
      def delete(path, opts={}, &bk)  route 'DELETE',  path, opts, &bk end
      def head(path, opts={}, &bk)    route 'HEAD',    path, opts, &bk end
      def options(path, opts={}, &bk) route 'OPTIONS', path, opts, &bk end

    private
      def route(verb, path, options={}, &block)
        # Because of self.options.host
        host_name(options.delete(:host)) if options.key?(:host)
        enable :empty_path_info if path == "" and empty_path_info.nil?

        block, pattern, keys, conditions = compile! verb, path, block, options
        invoke_hook(:route_added, verb, path, block)

        (@routes[verb] ||= []).
          push([pattern, keys, conditions, block]).last
      end

      def invoke_hook(name, *args)
        extensions.each { |e| e.send(name, *args) if e.respond_to?(name) }
      end

      def compile!(verb, path, block, options = {})
        options.each_pair { |option, args| send(option, *args) }
        method_name = "#{verb} #{path}"

        define_method(method_name, &block)
        unbound_method          = instance_method method_name
        pattern, keys           = compile(path)
        conditions, @conditions = @conditions, []
        remove_method method_name

        [ block.arity != 0 ?
            proc { unbound_method.bind(self).call(*@block_params) } :
            proc { unbound_method.bind(self).call },
          pattern, keys, conditions ]
      end

      def compile(path)
        keys = []
        if path.respond_to? :to_str
          special_chars = %w{. + ( ) $}
          pattern =
            path.to_str.gsub(/((:\w+)|[\*#{special_chars.join}])/) do |match|
              case match
              when "*"
                keys << 'splat'
                "(.*?)"
              when *special_chars
                Regexp.escape(match)
              else
                keys << $2[1..-1]
                "([^/?#]+)"
              end
            end
          [/^#{pattern}$/, keys]
        elsif path.respond_to?(:keys) && path.respond_to?(:match)
          [path, path.keys]
        elsif path.respond_to?(:names) && path.respond_to?(:match)
          [path, path.names]
        elsif path.respond_to? :match
          [path, keys]
        else
          raise TypeError, path
        end
      end

    public
      # Makes the methods defined in the block and in the Modules given
      # in `extensions` available to the handlers and templates
      def helpers(*extensions, &block)
        class_eval(&block)  if block_given?
        include(*extensions) if extensions.any?
      end

      # Register an extension. Alternatively take a block from which an
      # extension will be created and registered on the fly.
      def register(*extensions, &block)
        extensions << Module.new(&block) if block_given?
        @extensions += extensions
        extensions.each do |extension|
          extend extension
          extension.registered(self) if extension.respond_to?(:registered)
        end
      end

      def development?; environment == :development end
      def production?;  environment == :production  end
      def test?;        environment == :test        end

      # Set configuration options for Sinatra and/or the app.
      # Allows scoping of settings for certain environments.
      def configure(*envs, &block)
        yield self if envs.empty? || envs.include?(environment.to_sym)
      end

      # Use the specified Rack middleware
      def use(middleware, *args, &block)
        @prototype = nil
        @middleware << [middleware, args, block]
      end

      def quit!(server, handler_name)
        # Use Thin's hard #stop! if available, otherwise just #stop.
        server.respond_to?(:stop!) ? server.stop! : server.stop
        puts "\n== Sinatra has ended his set (crowd applauds)" unless handler_name =~/cgi/i
      end

      # Run the Sinatra app as a self-hosted server using
      # Thin, Mongrel or WEBrick (in that order)
      def run!(options={})
        set options
        handler      = detect_rack_handler
        handler_name = handler.name.gsub(/.*::/, '')
        puts "== Sinatra/#{Sinatra::VERSION} has taken the stage " +
          "on #{port} for #{environment} with backup from #{handler_name}" unless handler_name =~/cgi/i
        handler.run self, :Host => bind, :Port => port do |server|
          [:INT, :TERM].each { |sig| trap(sig) { quit!(server, handler_name) } }
          set :running, true
        end
      rescue Errno::EADDRINUSE => e
        puts "== Someone is already performing on port #{port}!"
      end

      # The prototype instance used to process requests.
      def prototype
        @prototype ||= new
      end

      # Create a new instance without middleware in front of it.
      alias new! new unless method_defined? :new!

      # Create a new instance of the class fronted by its middleware
      # pipeline. The object is guaranteed to respond to #call but may not be
      # an instance of the class new was called on.
      def new(*args, &bk)
        build(*args, &bk).to_app
      end

      # Creates a Rack::Builder instance with all the middleware set up and
      # an instance of this class as end point.
      def build(*args, &bk)
        builder = Rack::Builder.new
        builder.use Rack::MethodOverride if method_override?
        builder.use ShowExceptions       if show_exceptions?
        builder.use Rack::CommonLogger   if logging?
        builder.use Rack::Head
        setup_sessions builder
        middleware.each { |c,a,b| builder.use(c, *a, &b) }
        builder.run new!(*args, &bk)
        builder
      end

      def call(env)
        synchronize { prototype.call(env) }
      end

    private
      def setup_sessions(builder)
        return unless sessions?
        builder.use Rack::Session::Cookie, :secret => session_secret
      end

      def detect_rack_handler
        servers = Array(server)
        servers.each do |server_name|
          begin
            return Rack::Handler.get(server_name.downcase)
          rescue LoadError
          rescue NameError
          end
        end
        fail "Server handler (#{servers.join(',')}) not found."
      end

      def inherited(subclass)
        subclass.reset!
        super
      end

      @@mutex = Mutex.new
      def synchronize(&block)
        if lock?
          @@mutex.synchronize(&block)
        else
          yield
        end
      end

      def metadef(message, &block)
        (class << self; self; end).
          send :define_method, message, &block
      end

    public
      CALLERS_TO_IGNORE = [ # :nodoc:
        /\/sinatra(\/(base|main|showexceptions))?\.rb$/, # all sinatra code
        /lib\/tilt.*\.rb$/,                              # all tilt code
        /\(.*\)/,                                        # generated code
        /rubygems\/custom_require\.rb$/,                 # rubygems require hacks
        /active_support/,                                # active_support require hacks
        /bundler(\/runtime)?\.rb/,                       # bundler require hacks
        /<internal:/                                     # internal in ruby >= 1.9.2
      ]

      # add rubinius (and hopefully other VM impls) ignore patterns ...
      CALLERS_TO_IGNORE.concat(RUBY_IGNORE_CALLERS) if defined?(RUBY_IGNORE_CALLERS)

      # Like Kernel#caller but excluding certain magic entries and without
      # line / method information; the resulting array contains filenames only.
      def caller_files
        caller_locations.
          map { |file,line| file }
      end

      # Like caller_files, but containing Arrays rather than strings with the
      # first element being the file, and the second being the line.
      def caller_locations
        caller(1).
          map    { |line| line.split(/:(?=\d|in )/)[0,2] }.
          reject { |file,line| CALLERS_TO_IGNORE.any? { |pattern| file =~ pattern } }
      end
    end

    # Fixes encoding issues by
    # * defaulting to UTF-8
    # * casting params to Encoding.default_external
    #
    # The latter might not be necessary if Rack handles it one day.
    # Keep an eye on Rack's LH #100.
    def force_encoding(*args) settings.force_encoding(*args) end
    if defined? Encoding
      def self.force_encoding(data, encoding = default_encoding)
        return if data == settings || data.is_a?(Tempfile)
        if data.respond_to? :force_encoding
          data.force_encoding encoding
        elsif data.respond_to? :each_value
          data.each_value { |v| force_encoding(v, encoding) }
        elsif data.respond_to? :each
          data.each { |v| force_encoding(v, encoding) }
        end
        data
      end
    else
      def self.force_encoding(data, *) data end
      end

    reset!

    set :environment, (ENV['RACK_ENV'] || :development).to_sym
    set :raise_errors, Proc.new { test? }
    set :dump_errors, Proc.new { !test? }
    set :show_exceptions, Proc.new { development? }
    set :sessions, false
    set :logging, false
    set :method_override, false
    set :default_encoding, "utf-8"
    set :add_charset, [/^text\//, 'application/javascript', 'application/xml', 'application/xhtml+xml']

    # explicitly generating this eagerly to play nice with preforking
    set :session_secret, '%x' % rand(2**255)

    class << self
      alias_method :methodoverride?, :method_override?
      alias_method :methodoverride=, :method_override=
    end

    set :run, false                       # start server via at-exit hook?
    set :running, false                   # is the built-in server running now?
    set :server, %w[thin mongrel webrick]
    set :bind, '0.0.0.0'
    set :port, 4567

    set :absolute_redirects, true
    set :prefixed_redirects, false
    set :empty_path_info, nil

    set :app_file, nil
    set :root, Proc.new { app_file && File.expand_path(File.dirname(app_file)) }
    set :views, Proc.new { root && File.join(root, 'views') }
    set :reload_templates, Proc.new { development? or RUBY_VERSION < '1.8.7' }
    set :lock, false

    set :public, Proc.new { root && File.join(root, 'public') }
    set :static, Proc.new { public && File.exist?(public) }

    error ::Exception do
      response.status = 500
      content_type 'text/html'
      '<h1>Internal Server Error</h1>'
    end

    configure :development do
      get '/__sinatra__/:image.png' do
        filename = File.dirname(__FILE__) + "/images/#{params[:image]}.png"
        content_type :png
        send_file filename
      end

      error NotFound do
        content_type 'text/html'

        (<<-HTML).gsub(/^ {8}/, '')
        <!DOCTYPE html>
        <html>
        <head>
          <style type="text/css">
          body { text-align:center;font-family:helvetica,arial;font-size:22px;
            color:#888;margin:20px}
          #c {margin:0 auto;width:500px;text-align:left}
          </style>
        </head>
        <body>
          <h2>Sinatra doesn&rsquo;t know this ditty.</h2>
          <img src='#{uri "/__sinatra__/404.png"}'>
          <div id="c">
            Try this:
            <pre>#{request.request_method.downcase} '#{request.path_info}' do\n  "Hello World"\nend</pre>
          </div>
        </body>
        </html>
        HTML
      end
    end
  end

  # Execution context for classic style (top-level) applications. All
  # DSL methods executed on main are delegated to this class.
  #
  # The Application class should not be subclassed, unless you want to
  # inherit all settings, routes, handlers, and error pages from the
  # top-level. Subclassing Sinatra::Base is heavily recommended for
  # modular applications.
  class Application < Base
    set :logging, Proc.new { ! test? }
    set :method_override, true
    set :run, Proc.new { ! test? }
    set :session_secret, Proc.new { super() unless development? }

    def self.register(*extensions, &block) #:nodoc:
      added_methods = extensions.map {|m| m.public_instance_methods }.flatten
      Delegator.delegate(*added_methods)
      super(*extensions, &block)
    end
  end

  # Sinatra delegation mixin. Mixing this module into an object causes all
  # methods to be delegated to the Sinatra::Application class. Used primarily
  # at the top-level.
  module Delegator #:nodoc:
    TEMPLATE = <<-RUBY
      def %1$s(*args, &b)
        return super if respond_to? :%1$s
        ::Sinatra::Delegator.target.send("%2$s", *args, &b)
      end
    RUBY

    def self.delegate(*methods)
      methods.each do |method_name|
        # Replaced with way shorter and better implementation in 1.3.0
        # using define_method instead, however, blocks cannot take block
        # arguments on 1.8.6.
        begin
          code = TEMPLATE % [method_name, method_name]
          eval code, binding, '(__DELEGATE__)', 1
        rescue SyntaxError
          code  = TEMPLATE % [:_delegate, method_name]
          eval code, binding, '(__DELEGATE__)', 1
          alias_method method_name, :_delegate
          undef_method :_delegate
        end
        private method_name
      end
    end

    delegate :get, :put, :post, :delete, :head, :options, :template, :layout,
             :before, :after, :error, :not_found, :configure, :set, :mime_type,
             :enable, :disable, :use, :development?, :test?, :production?,
             :helpers, :settings

    class << self
      attr_accessor :target
    end

    self.target = Application
  end

  # Create a new Sinatra application. The block is evaluated in the new app's
  # class scope.
  def self.new(base=Base, options={}, &block)
    base = Class.new(base)
    base.class_eval(&block) if block_given?
    base
  end

  # Extend the top-level DSL with the modules provided.
  def self.register(*extensions, &block)
    Delegator.target.register(*extensions, &block)
  end

  # Include the helper modules provided in Sinatra's request context.
  def self.helpers(*extensions, &block)
    Delegator.target.helpers(*extensions, &block)
  end
end
