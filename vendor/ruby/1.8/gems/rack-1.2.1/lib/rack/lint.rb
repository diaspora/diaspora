require 'rack/utils'

module Rack
  # Rack::Lint validates your application and the requests and
  # responses according to the Rack spec.

  class Lint
    def initialize(app)
      @app = app
      @content_length = nil
    end

    # :stopdoc:

    class LintError < RuntimeError; end
    module Assertion
      def assert(message, &block)
        unless block.call
          raise LintError, message
        end
      end
    end
    include Assertion

    ## This specification aims to formalize the Rack protocol.  You
    ## can (and should) use Rack::Lint to enforce it.
    ##
    ## When you develop middleware, be sure to add a Lint before and
    ## after to catch all mistakes.

    ## = Rack applications

    ## A Rack application is an Ruby object (not a class) that
    ## responds to +call+.
    def call(env=nil)
      dup._call(env)
    end

    def _call(env)
      ## It takes exactly one argument, the *environment*
      assert("No env given") { env }
      check_env env

      env['rack.input'] = InputWrapper.new(env['rack.input'])
      env['rack.errors'] = ErrorWrapper.new(env['rack.errors'])

      ## and returns an Array of exactly three values:
      status, headers, @body = @app.call(env)
      ## The *status*,
      check_status status
      ## the *headers*,
      check_headers headers
      ## and the *body*.
      check_content_type status, headers
      check_content_length status, headers
      @head_request = env["REQUEST_METHOD"] == "HEAD"
      [status, headers, self]
    end

    ## == The Environment
    def check_env(env)
      ## The environment must be an instance of Hash that includes
      ## CGI-like headers.  The application is free to modify the
      ## environment.
      assert("env #{env.inspect} is not a Hash, but #{env.class}") {
        env.kind_of? Hash
      }

      ##
      ## The environment is required to include these variables
      ## (adopted from PEP333), except when they'd be empty, but see
      ## below.

      ## <tt>REQUEST_METHOD</tt>:: The HTTP request method, such as
      ##                           "GET" or "POST". This cannot ever
      ##                           be an empty string, and so is
      ##                           always required.

      ## <tt>SCRIPT_NAME</tt>:: The initial portion of the request
      ##                        URL's "path" that corresponds to the
      ##                        application object, so that the
      ##                        application knows its virtual
      ##                        "location". This may be an empty
      ##                        string, if the application corresponds
      ##                        to the "root" of the server.

      ## <tt>PATH_INFO</tt>:: The remainder of the request URL's
      ##                      "path", designating the virtual
      ##                      "location" of the request's target
      ##                      within the application. This may be an
      ##                      empty string, if the request URL targets
      ##                      the application root and does not have a
      ##                      trailing slash. This value may be
      ##                      percent-encoded when I originating from
      ##                      a URL.

      ## <tt>QUERY_STRING</tt>:: The portion of the request URL that
      ##                         follows the <tt>?</tt>, if any. May be
      ##                         empty, but is always required!

      ## <tt>SERVER_NAME</tt>, <tt>SERVER_PORT</tt>:: When combined with <tt>SCRIPT_NAME</tt> and <tt>PATH_INFO</tt>, these variables can be used to complete the URL. Note, however, that <tt>HTTP_HOST</tt>, if present, should be used in preference to <tt>SERVER_NAME</tt> for reconstructing the request URL.  <tt>SERVER_NAME</tt> and <tt>SERVER_PORT</tt> can never be empty strings, and so are always required.

      ## <tt>HTTP_</tt> Variables:: Variables corresponding to the
      ##                            client-supplied HTTP request
      ##                            headers (i.e., variables whose
      ##                            names begin with <tt>HTTP_</tt>). The
      ##                            presence or absence of these
      ##                            variables should correspond with
      ##                            the presence or absence of the
      ##                            appropriate HTTP header in the
      ##                            request.

      ## In addition to this, the Rack environment must include these
      ## Rack-specific variables:

      ## <tt>rack.version</tt>:: The Array [1,1], representing this version of Rack.
      ## <tt>rack.url_scheme</tt>:: +http+ or +https+, depending on the request URL.
      ## <tt>rack.input</tt>:: See below, the input stream.
      ## <tt>rack.errors</tt>:: See below, the error stream.
      ## <tt>rack.multithread</tt>:: true if the application object may be simultaneously invoked by another thread in the same process, false otherwise.
      ## <tt>rack.multiprocess</tt>:: true if an equivalent application object may be simultaneously invoked by another process, false otherwise.
      ## <tt>rack.run_once</tt>:: true if the server expects (but does not guarantee!) that the application will only be invoked this one time during the life of its containing process. Normally, this will only be true for a server based on CGI (or something similar).
      ##

      ## Additional environment specifications have approved to
      ## standardized middleware APIs.  None of these are required to
      ## be implemented by the server.

      ## <tt>rack.session</tt>:: A hash like interface for storing request session data.
      ##                         The store must implement:
      if session = env['rack.session']
        ##                         store(key, value)         (aliased as []=);
        assert("session #{session.inspect} must respond to store and []=") {
          session.respond_to?(:store) && session.respond_to?(:[]=)
        }

        ##                         fetch(key, default = nil) (aliased as []);
        assert("session #{session.inspect} must respond to fetch and []") {
          session.respond_to?(:fetch) && session.respond_to?(:[])
        }

        ##                         delete(key);
        assert("session #{session.inspect} must respond to delete") {
          session.respond_to?(:delete)
        }

        ##                         clear;
        assert("session #{session.inspect} must respond to clear") {
          session.respond_to?(:clear)
        }
      end

      ## <tt>rack.logger</tt>:: A common object interface for logging messages.
      ##                        The object must implement:
      if logger = env['rack.logger']
        ##                         info(message, &block)
        assert("logger #{logger.inspect} must respond to info") {
          logger.respond_to?(:info)
        }

        ##                         debug(message, &block)
        assert("logger #{logger.inspect} must respond to debug") {
          logger.respond_to?(:debug)
        }

        ##                         warn(message, &block)
        assert("logger #{logger.inspect} must respond to warn") {
          logger.respond_to?(:warn)
        }

        ##                         error(message, &block)
        assert("logger #{logger.inspect} must respond to error") {
          logger.respond_to?(:error)
        }

        ##                         fatal(message, &block)
        assert("logger #{logger.inspect} must respond to fatal") {
          logger.respond_to?(:fatal)
        }
      end

      ## The server or the application can store their own data in the
      ## environment, too.  The keys must contain at least one dot,
      ## and should be prefixed uniquely.  The prefix <tt>rack.</tt>
      ## is reserved for use with the Rack core distribution and other
      ## accepted specifications and must not be used otherwise.
      ##

      %w[REQUEST_METHOD SERVER_NAME SERVER_PORT
         QUERY_STRING
         rack.version rack.input rack.errors
         rack.multithread rack.multiprocess rack.run_once].each { |header|
        assert("env missing required key #{header}") { env.include? header }
      }

      ## The environment must not contain the keys
      ## <tt>HTTP_CONTENT_TYPE</tt> or <tt>HTTP_CONTENT_LENGTH</tt>
      ## (use the versions without <tt>HTTP_</tt>).
      %w[HTTP_CONTENT_TYPE HTTP_CONTENT_LENGTH].each { |header|
        assert("env contains #{header}, must use #{header[5,-1]}") {
          not env.include? header
        }
      }

      ## The CGI keys (named without a period) must have String values.
      env.each { |key, value|
        next  if key.include? "."   # Skip extensions
        assert("env variable #{key} has non-string value #{value.inspect}") {
          value.kind_of? String
        }
      }

      ##
      ## There are the following restrictions:

      ## * <tt>rack.version</tt> must be an array of Integers.
      assert("rack.version must be an Array, was #{env["rack.version"].class}") {
        env["rack.version"].kind_of? Array
      }
      ## * <tt>rack.url_scheme</tt> must either be +http+ or +https+.
      assert("rack.url_scheme unknown: #{env["rack.url_scheme"].inspect}") {
        %w[http https].include? env["rack.url_scheme"]
      }

      ## * There must be a valid input stream in <tt>rack.input</tt>.
      check_input env["rack.input"]
      ## * There must be a valid error stream in <tt>rack.errors</tt>.
      check_error env["rack.errors"]

      ## * The <tt>REQUEST_METHOD</tt> must be a valid token.
      assert("REQUEST_METHOD unknown: #{env["REQUEST_METHOD"]}") {
        env["REQUEST_METHOD"] =~ /\A[0-9A-Za-z!\#$%&'*+.^_`|~-]+\z/
      }

      ## * The <tt>SCRIPT_NAME</tt>, if non-empty, must start with <tt>/</tt>
      assert("SCRIPT_NAME must start with /") {
        !env.include?("SCRIPT_NAME") ||
        env["SCRIPT_NAME"] == "" ||
        env["SCRIPT_NAME"] =~ /\A\//
      }
      ## * The <tt>PATH_INFO</tt>, if non-empty, must start with <tt>/</tt>
      assert("PATH_INFO must start with /") {
        !env.include?("PATH_INFO") ||
        env["PATH_INFO"] == "" ||
        env["PATH_INFO"] =~ /\A\//
      }
      ## * The <tt>CONTENT_LENGTH</tt>, if given, must consist of digits only.
      assert("Invalid CONTENT_LENGTH: #{env["CONTENT_LENGTH"]}") {
        !env.include?("CONTENT_LENGTH") || env["CONTENT_LENGTH"] =~ /\A\d+\z/
      }

      ## * One of <tt>SCRIPT_NAME</tt> or <tt>PATH_INFO</tt> must be
      ##   set.  <tt>PATH_INFO</tt> should be <tt>/</tt> if
      ##   <tt>SCRIPT_NAME</tt> is empty.
      assert("One of SCRIPT_NAME or PATH_INFO must be set (make PATH_INFO '/' if SCRIPT_NAME is empty)") {
        env["SCRIPT_NAME"] || env["PATH_INFO"]
      }
      ##   <tt>SCRIPT_NAME</tt> never should be <tt>/</tt>, but instead be empty.
      assert("SCRIPT_NAME cannot be '/', make it '' and PATH_INFO '/'") {
        env["SCRIPT_NAME"] != "/"
      }
    end

    ## === The Input Stream
    ##
    ## The input stream is an IO-like object which contains the raw HTTP
    ## POST data.
    def check_input(input)
      ## When applicable, its external encoding must be "ASCII-8BIT" and it
      ## must be opened in binary mode, for Ruby 1.9 compatibility.
      assert("rack.input #{input} does not have ASCII-8BIT as its external encoding") {
        input.external_encoding.name == "ASCII-8BIT"
      } if input.respond_to?(:external_encoding)
      assert("rack.input #{input} is not opened in binary mode") {
        input.binmode?
      } if input.respond_to?(:binmode?)

      ## The input stream must respond to +gets+, +each+, +read+ and +rewind+.
      [:gets, :each, :read, :rewind].each { |method|
        assert("rack.input #{input} does not respond to ##{method}") {
          input.respond_to? method
        }
      }
    end

    class InputWrapper
      include Assertion

      def initialize(input)
        @input = input
      end

      ## * +gets+ must be called without arguments and return a string,
      ##   or +nil+ on EOF.
      def gets(*args)
        assert("rack.input#gets called with arguments") { args.size == 0 }
        v = @input.gets
        assert("rack.input#gets didn't return a String") {
          v.nil? or v.kind_of? String
        }
        v
      end

      ## * +read+ behaves like IO#read. Its signature is <tt>read([length, [buffer]])</tt>.
      ##   If given, +length+ must be an non-negative Integer (>= 0) or +nil+, and +buffer+ must
      ##   be a String and may not be nil. If +length+ is given and not nil, then this method
      ##   reads at most +length+ bytes from the input stream. If +length+ is not given or nil,
      ##   then this method reads all data until EOF.
      ##   When EOF is reached, this method returns nil if +length+ is given and not nil, or ""
      ##   if +length+ is not given or is nil.
      ##   If +buffer+ is given, then the read data will be placed into +buffer+ instead of a
      ##   newly created String object.
      def read(*args)
        assert("rack.input#read called with too many arguments") {
          args.size <= 2
        }
        if args.size >= 1
          assert("rack.input#read called with non-integer and non-nil length") {
            args.first.kind_of?(Integer) || args.first.nil?
          }
          assert("rack.input#read called with a negative length") {
            args.first.nil? || args.first >= 0
          }
        end
        if args.size >= 2
          assert("rack.input#read called with non-String buffer") {
            args[1].kind_of?(String)
          }
        end

        v = @input.read(*args)

        assert("rack.input#read didn't return nil or a String") {
          v.nil? or v.kind_of? String
        }
        if args[0].nil?
          assert("rack.input#read(nil) returned nil on EOF") {
            !v.nil?
          }
        end

        v
      end

      ## * +each+ must be called without arguments and only yield Strings.
      def each(*args)
        assert("rack.input#each called with arguments") { args.size == 0 }
        @input.each { |line|
          assert("rack.input#each didn't yield a String") {
            line.kind_of? String
          }
          yield line
        }
      end

      ## * +rewind+ must be called without arguments. It rewinds the input
      ##   stream back to the beginning. It must not raise Errno::ESPIPE:
      ##   that is, it may not be a pipe or a socket. Therefore, handler
      ##   developers must buffer the input data into some rewindable object
      ##   if the underlying input stream is not rewindable.
      def rewind(*args)
        assert("rack.input#rewind called with arguments") { args.size == 0 }
        assert("rack.input#rewind raised Errno::ESPIPE") {
          begin
            @input.rewind
            true
          rescue Errno::ESPIPE
            false
          end
        }
      end

      ## * +close+ must never be called on the input stream.
      def close(*args)
        assert("rack.input#close must not be called") { false }
      end
    end

    ## === The Error Stream
    def check_error(error)
      ## The error stream must respond to +puts+, +write+ and +flush+.
      [:puts, :write, :flush].each { |method|
        assert("rack.error #{error} does not respond to ##{method}") {
          error.respond_to? method
        }
      }
    end

    class ErrorWrapper
      include Assertion

      def initialize(error)
        @error = error
      end

      ## * +puts+ must be called with a single argument that responds to +to_s+.
      def puts(str)
        @error.puts str
      end

      ## * +write+ must be called with a single argument that is a String.
      def write(str)
        assert("rack.errors#write not called with a String") { str.kind_of? String }
        @error.write str
      end

      ## * +flush+ must be called without arguments and must be called
      ##   in order to make the error appear for sure.
      def flush
        @error.flush
      end

      ## * +close+ must never be called on the error stream.
      def close(*args)
        assert("rack.errors#close must not be called") { false }
      end
    end

    ## == The Response

    ## === The Status
    def check_status(status)
      ## This is an HTTP status. When parsed as integer (+to_i+), it must be
      ## greater than or equal to 100.
      assert("Status must be >=100 seen as integer") { status.to_i >= 100 }
    end

    ## === The Headers
    def check_headers(header)
      ## The header must respond to +each+, and yield values of key and value.
      assert("headers object should respond to #each, but doesn't (got #{header.class} as headers)") {
         header.respond_to? :each
      }
      header.each { |key, value|
        ## The header keys must be Strings.
        assert("header key must be a string, was #{key.class}") {
          key.kind_of? String
        }
        ## The header must not contain a +Status+ key,
        assert("header must not contain Status") { key.downcase != "status" }
        ## contain keys with <tt>:</tt> or newlines in their name,
        assert("header names must not contain : or \\n") { key !~ /[:\n]/ }
        ## contain keys names that end in <tt>-</tt> or <tt>_</tt>,
        assert("header names must not end in - or _") { key !~ /[-_]\z/ }
        ## but only contain keys that consist of
        ## letters, digits, <tt>_</tt> or <tt>-</tt> and start with a letter.
        assert("invalid header name: #{key}") { key =~ /\A[a-zA-Z][a-zA-Z0-9_-]*\z/ }

        ## The values of the header must be Strings,
        assert("a header value must be a String, but the value of " +
          "'#{key}' is a #{value.class}") { value.kind_of? String }
        ## consisting of lines (for multiple header values, e.g. multiple
        ## <tt>Set-Cookie</tt> values) seperated by "\n".
        value.split("\n").each { |item|
          ## The lines must not contain characters below 037.
          assert("invalid header value #{key}: #{item.inspect}") {
            item !~ /[\000-\037]/
          }
        }
      }
    end

    ## === The Content-Type
    def check_content_type(status, headers)
      headers.each { |key, value|
        ## There must be a <tt>Content-Type</tt>, except when the
        ## +Status+ is 1xx, 204 or 304, in which case there must be none
        ## given.
        if key.downcase == "content-type"
          assert("Content-Type header found in #{status} response, not allowed") {
            not Rack::Utils::STATUS_WITH_NO_ENTITY_BODY.include? status.to_i
          }
          return
        end
      }
      assert("No Content-Type header found") {
        Rack::Utils::STATUS_WITH_NO_ENTITY_BODY.include? status.to_i
      }
    end

    ## === The Content-Length
    def check_content_length(status, headers)
      headers.each { |key, value|
        if key.downcase == 'content-length'
          ## There must not be a <tt>Content-Length</tt> header when the
          ## +Status+ is 1xx, 204 or 304.
          assert("Content-Length header found in #{status} response, not allowed") {
            not Rack::Utils::STATUS_WITH_NO_ENTITY_BODY.include? status.to_i
          }
          @content_length = value
        end
      }
    end

    def verify_content_length(bytes)
      if @head_request
        assert("Response body was given for HEAD request, but should be empty") {
          bytes == 0
        }
      elsif @content_length
        assert("Content-Length header was #{@content_length}, but should be #{bytes}") {
          @content_length == bytes.to_s
        }
      end
    end

    ## === The Body
    def each
      @closed = false
      bytes = 0

      ## The Body must respond to +each+
      assert("Response body must respond to each") do
        @body.respond_to?(:each)
      end

      @body.each { |part|
        ## and must only yield String values.
        assert("Body yielded non-string value #{part.inspect}") {
          part.kind_of? String
        }
        bytes += Rack::Utils.bytesize(part)
        yield part
      }
      verify_content_length(bytes)

      ##
      ## The Body itself should not be an instance of String, as this will
      ## break in Ruby 1.9.
      ##
      ## If the Body responds to +close+, it will be called after iteration.
      # XXX howto: assert("Body has not been closed") { @closed }


      ##
      ## If the Body responds to +to_path+, it must return a String
      ## identifying the location of a file whose contents are identical
      ## to that produced by calling +each+; this may be used by the
      ## server as an alternative, possibly more efficient way to
      ## transport the response.

      if @body.respond_to?(:to_path)
        assert("The file identified by body.to_path does not exist") {
          ::File.exist? @body.to_path
        }
      end

      ##
      ## The Body commonly is an Array of Strings, the application
      ## instance itself, or a File-like object.
    end

    def close
      @closed = true
      @body.close  if @body.respond_to?(:close)
    end

    # :startdoc:

  end
end

## == Thanks
## Some parts of this specification are adopted from PEP333: Python
## Web Server Gateway Interface
## v1.0 (http://www.python.org/dev/peps/pep-0333/). I'd like to thank
## everyone involved in that effort.
