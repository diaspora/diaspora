require 'optparse'
require 'oauth'

module OAuth
  class CLI
    SUPPORTED_COMMANDS = {
      "authorize" => "Obtain an access token and secret for a user",
      "debug"     => "Verbosely generate an OAuth signature",
      "query"     => "Query a protected resource",
      "sign"      => "Generate an OAuth signature",
      "version"   => "Display the current version of the library"
    }

    attr_reader :command
    attr_reader :options
    attr_reader :stdout, :stdin

    def self.execute(stdout, stdin, stderr, arguments = [])
      self.new.execute(stdout, stdin, stderr, arguments)
    end

    def initialize
      @options = {}

      # don't dump a backtrace on a ^C
      trap(:INT) {
        exit
      }
    end

    def execute(stdout, stdin, stderr, arguments = [])
      @stdout = stdout
      @stdin  = stdin
      @stderr = stderr
      extract_command_and_parse_options(arguments)

      if sufficient_options? && valid_command?
        if command == "debug"
          @command = "sign"
          @options[:verbose] = true
        end

        case command
        # TODO move command logic elsewhere
        when "authorize"
          begin
            consumer = OAuth::Consumer.new \
              options[:oauth_consumer_key],
              options[:oauth_consumer_secret],
              :access_token_url  => options[:access_token_url],
              :authorize_url     => options[:authorize_url],
              :request_token_url => options[:request_token_url],
              :scheme            => options[:scheme],
              :http_method       => options[:method].to_s.downcase.to_sym

            # parameters for OAuth 1.0a
            oauth_verifier = nil

            # get a request token
            request_token = consumer.get_request_token({ :oauth_callback => options[:oauth_callback] }, { "scope" => options[:scope] })

            if request_token.callback_confirmed?
              stdout.puts "Server appears to support OAuth 1.0a; enabling support."
              options[:version] = "1.0a"
            end

            stdout.puts "Please visit this url to authorize:"
            stdout.puts request_token.authorize_url

            if options[:version] == "1.0a"
              stdout.puts "Please enter the verification code provided by the SP (oauth_verifier):"
              oauth_verifier = stdin.gets.chomp
            else
              stdout.puts "Press return to continue..."
              stdin.gets
            end

            begin
              # get an access token
              access_token = request_token.get_access_token(:oauth_verifier => oauth_verifier)

              stdout.puts "Response:"
              access_token.params.each do |k,v|
                stdout.puts "  #{k}: #{v}" unless k.is_a?(Symbol)
              end
            rescue OAuth::Unauthorized => e
              stderr.puts "A problem occurred while attempting to obtain an access token:"
              stderr.puts e
              stderr.puts e.request.body
            end
          rescue OAuth::Unauthorized => e
            stderr.puts "A problem occurred while attempting to authorize:"
            stderr.puts e
            stderr.puts e.request.body
          end
        when "query"
          consumer = OAuth::Consumer.new \
            options[:oauth_consumer_key],
            options[:oauth_consumer_secret],
            :scheme => options[:scheme]

          access_token = OAuth::AccessToken.new(consumer, options[:oauth_token], options[:oauth_token_secret])

          # append params to the URL
          uri = URI.parse(options[:uri])
          params = prepare_parameters.map { |k,v| v.map { |v2| "#{URI.encode(k)}=#{URI.encode(v2)}" } * "&" }
          uri.query = [uri.query, *params].reject { |x| x.nil? } * "&"
          p uri.to_s

          response = access_token.request(options[:method].downcase.to_sym, uri.to_s)
          puts "#{response.code} #{response.message}"
          puts response.body
        when "sign"
          parameters = prepare_parameters

          request = OAuth::RequestProxy.proxy \
             "method"     => options[:method],
             "uri"        => options[:uri],
             "parameters" => parameters

          if verbose?
            stdout.puts "OAuth parameters:"
            request.oauth_parameters.each do |k,v|
              stdout.puts "  " + [k, v] * ": "
            end
            stdout.puts

            if request.non_oauth_parameters.any?
              stdout.puts "Parameters:"
              request.non_oauth_parameters.each do |k,v|
                stdout.puts "  " + [k, v] * ": "
              end
              stdout.puts
            end
          end

          request.sign! \
            :consumer_secret => options[:oauth_consumer_secret],
            :token_secret    => options[:oauth_token_secret]

          if verbose?
            stdout.puts "Method: #{request.method}"
            stdout.puts "URI: #{request.uri}"
            stdout.puts "Normalized params: #{request.normalized_parameters}" unless options[:xmpp]
            stdout.puts "Signature base string: #{request.signature_base_string}"

            if options[:xmpp]
              stdout.puts
              stdout.puts "XMPP Stanza:"
              stdout.puts <<-EOS
  <oauth xmlns='urn:xmpp:oauth:0'>
    <oauth_consumer_key>#{request.oauth_consumer_key}</oauth_consumer_key>
    <oauth_token>#{request.oauth_token}</oauth_token>
    <oauth_signature_method>#{request.oauth_signature_method}</oauth_signature_method>
    <oauth_signature>#{request.oauth_signature}</oauth_signature>
    <oauth_timestamp>#{request.oauth_timestamp}</oauth_timestamp>
    <oauth_nonce>#{request.oauth_nonce}</oauth_nonce>
    <oauth_version>#{request.oauth_version}</oauth_version>
  </oauth>
              EOS
              stdout.puts
              stdout.puts "Note: You may want to use bare JIDs in your URI."
              stdout.puts
            else
              stdout.puts "OAuth Request URI: #{request.signed_uri}"
              stdout.puts "Request URI: #{request.signed_uri(false)}"
              stdout.puts "Authorization header: #{request.oauth_header(:realm => options[:realm])}"
            end
            stdout.puts "Signature:         #{request.oauth_signature}"
            stdout.puts "Escaped signature: #{OAuth::Helper.escape(request.oauth_signature)}"
          else
            stdout.puts request.oauth_signature
          end
        when "version"
          puts "OAuth for Ruby #{OAuth::VERSION}"
        end
      else
        usage
      end
    end

  protected

    def extract_command_and_parse_options(arguments)
      @command = arguments[-1]
      parse_options(arguments[0..-1])
    end

    def option_parser(arguments = "")
      # TODO add realm parameter
      # TODO add user-agent parameter
      option_parser = OptionParser.new do |opts|
        opts.banner = "Usage: #{$0} [options] <command>"

        # defaults
        options[:oauth_nonce] = OAuth::Helper.generate_key
        options[:oauth_signature_method] = "HMAC-SHA1"
        options[:oauth_timestamp] = OAuth::Helper.generate_timestamp
        options[:oauth_version] = "1.0"
        options[:method] = :post
        options[:params] = []
        options[:scheme] = :header
        options[:version] = "1.0"

        ## Common Options

        opts.on("-B", "--body", "Use the request body for OAuth parameters.") do
          options[:scheme] = :body
        end

        opts.on("--consumer-key KEY", "Specifies the consumer key to use.") do |v|
          options[:oauth_consumer_key] = v
        end

        opts.on("--consumer-secret SECRET", "Specifies the consumer secret to use.") do |v|
          options[:oauth_consumer_secret] = v
        end

        opts.on("-H", "--header", "Use the 'Authorization' header for OAuth parameters (default).") do
          options[:scheme] = :header
        end

        opts.on("-Q", "--query-string", "Use the query string for OAuth parameters.") do
          options[:scheme] = :query_string
        end

        opts.on("-O", "--options FILE", "Read options from a file") do |v|
          arguments.unshift(*open(v).readlines.map { |l| l.chomp.split(" ") }.flatten)
        end

        ## Options for signing and making requests

        opts.separator("\n  options for signing and querying")

        opts.on("--method METHOD", "Specifies the method (e.g. GET) to use when signing.") do |v|
          options[:method] = v
        end

        opts.on("--nonce NONCE", "Specifies the none to use.") do |v|
          options[:oauth_nonce] = v
        end

        opts.on("--parameters PARAMS", "Specifies the parameters to use when signing.") do |v|
          options[:params] << v
        end

        opts.on("--signature-method METHOD", "Specifies the signature method to use; defaults to HMAC-SHA1.") do |v|
          options[:oauth_signature_method] = v
        end

        opts.on("--secret SECRET", "Specifies the token secret to use.") do |v|
          options[:oauth_token_secret] = v
        end

        opts.on("--timestamp TIMESTAMP", "Specifies the timestamp to use.") do |v|
          options[:oauth_timestamp] = v
        end

        opts.on("--token TOKEN", "Specifies the token to use.") do |v|
          options[:oauth_token] = v
        end

        opts.on("--realm REALM", "Specifies the realm to use.") do |v|
          options[:realm] = v
        end

        opts.on("--uri URI", "Specifies the URI to use when signing.") do |v|
          options[:uri] = v
        end

        opts.on(:OPTIONAL, "--version VERSION", "Specifies the OAuth version to use.") do |v|
          if v
            options[:oauth_version] = v
          else
            @command = "version"
          end
        end

        opts.on("--no-version", "Omit oauth_version.") do
          options[:oauth_version] = nil
        end

        opts.on("--xmpp", "Generate XMPP stanzas.") do
          options[:xmpp] = true
          options[:method] ||= "iq"
        end

        opts.on("-v", "--verbose", "Be verbose.") do
          options[:verbose] = true
        end

        ## Options for authorization

        opts.separator("\n  options for authorization")

        opts.on("--access-token-url URL", "Specifies the access token URL.") do |v|
          options[:access_token_url] = v
        end

        opts.on("--authorize-url URL", "Specifies the authorization URL.") do |v|
          options[:authorize_url] = v
        end

        opts.on("--callback-url URL", "Specifies a callback URL.") do |v|
          options[:oauth_callback] = v
        end

        opts.on("--request-token-url URL", "Specifies the request token URL.") do |v|
          options[:request_token_url] = v
        end

        opts.on("--scope SCOPE", "Specifies the scope (Google-specific).") do |v|
          options[:scope] = v
        end
      end
    end

    def parse_options(arguments)
      option_parser(arguments).parse!(arguments)
    end

    def prepare_parameters
      escaped_pairs = options[:params].collect do |pair|
        if pair =~ /:/
          Hash[*pair.split(":", 2)].collect do |k,v|
            [CGI.escape(k.strip), CGI.escape(v.strip)] * "="
          end
        else
          pair
        end
      end

      querystring = escaped_pairs * "&"
      cli_params = CGI.parse(querystring)

      {
        "oauth_consumer_key"     => options[:oauth_consumer_key],
        "oauth_nonce"            => options[:oauth_nonce],
        "oauth_timestamp"        => options[:oauth_timestamp],
        "oauth_token"            => options[:oauth_token],
        "oauth_signature_method" => options[:oauth_signature_method],
        "oauth_version"          => options[:oauth_version]
      }.reject { |k,v| v.nil? || v == "" }.merge(cli_params)
    end

    def sufficient_options?
      case command
      # TODO move command logic elsewhere
      when "authorize"
        options[:oauth_consumer_key] && options[:oauth_consumer_secret] &&
          options[:access_token_url] && options[:authorize_url] &&
          options[:request_token_url]
      when "version"
        true
      else
        options[:oauth_consumer_key] && options[:oauth_consumer_secret] &&
          options[:method] && options[:uri]
      end
    end

    def usage
      stdout.puts option_parser.help
      stdout.puts
      stdout.puts "Available commands:"
      SUPPORTED_COMMANDS.each do |command, desc|
        puts "   #{command.ljust(15)}#{desc}"
      end
    end

    def valid_command?
      SUPPORTED_COMMANDS.keys.include?(command)
    end

    def verbose?
      options[:verbose]
    end
  end
end
