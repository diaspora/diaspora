#this code boughts pieces from activeldap and net-ldap

require 'rack'
require 'net/ldap'
require 'net/ntlm'
require 'uri'

module OmniAuth
  module Strategies
    class LDAP
      class Adaptor
        class LdapError < StandardError; end
        class ConfigurationError < StandardError; end
        class AuthenticationError < StandardError; end
        class ConnectionError < StandardError; end

        VALID_ADAPTER_CONFIGURATION_KEYS = [:host, :port, :method, :bind_dn, :password,
	                                        :try_sasl, :sasl_mechanisms, :uid, :base, :allow_anonymous]

        MUST_HAVE_KEYS = [:host, :port, :method, :uid, :base]

        METHOD = {
	        :ssl => :simple_tls,
	        :tls => :start_tls,
          :plain => nil,
        }

        attr_accessor :bind_dn, :password
        attr_reader :connection, :uid, :base

        def initialize(configuration={})
          @connection = nil
          @disconnected = false
          @bound = false
          @configuration = configuration.dup
          @configuration[:allow_anonymous] ||= false
          @logger = @configuration.delete(:logger)
          message = []
          MUST_HAVE_KEYS.each do |name|
              message << name if configuration[name].nil?
          end
          raise ArgumentError.new(message.join(",") +" MUST be provided") unless message.empty?
          VALID_ADAPTER_CONFIGURATION_KEYS.each do |name|
            instance_variable_set("@#{name}", configuration[name])
          end
        end

        def connect(options={})
          host = options[:host] || @host
          method = ensure_method(options[:method] || @method || :plain)
          port = options[:port] || @port || ensure_port(method)
          @disconnected = false
          @bound = false
          @bind_tried = false

          config = {
            :host => host,
            :port => port,
          }

          config[:encryption] = {:method => method} if method

          @connection, @uri, @with_start_tls = begin
            uri = construct_uri(host, port, method == :simple_tls)
            with_start_tls = method == :start_tls
            puts ({:uri => uri, :with_start_tls => with_start_tls}).inspect
            [Net::LDAP::Connection.new(config), uri, with_start_tls]
          rescue Net::LDAP::LdapError
            raise ConnectionError, $!.message
          end
        end

        def unbind(options={})
          @connection.close # Net::LDAP doesn't implement unbind.
        end

        def bind(options={})
          connect(options) unless connecting?
          begin
          @bind_tried = true

          bind_dn = (options[:bind_dn] || @bind_dn).to_s
          try_sasl = options.has_key?(:try_sasl) ? options[:try_sasl] : @try_sasl
          if options.has_key?(:allow_anonymous)
            allow_anonymous = options[:allow_anonymous]
          else
            allow_anonymous = @allow_anonymous
          end
          # Rough bind loop:
          # Attempt 1: SASL if available
          # Attempt 2: SIMPLE with credentials if password block
          # Attempt 3: SIMPLE ANONYMOUS if 1 and 2 fail and allow anonymous is set to true
          if try_sasl and sasl_bind(bind_dn, options)
              puts "bound with sasl"
          elsif simple_bind(bind_dn, options)
              puts "bound with simple"
          elsif allow_anonymous and bind_as_anonymous(options)
            puts "bound as anonymous"
          else
            message = yield if block_given?
            message ||= ('All authentication methods for %s exhausted.') % target
            raise AuthenticationError, message
          end
          @bound = true
          rescue Net::LDAP::LdapError
            raise AuthenticationError, $!.message
          end
        end

        def disconnect!(options={})
          unbind(options)
          @connection = @uri = @with_start_tls = nil
          @disconnected = true
        end

        def rebind(options={})
          unbind(options) if bound?
          connect(options)
        end

        def connecting?
          !@connection.nil? and !@disconnected
        end

        def bound?
          connecting? and @bound
        end

        def search(options={}, &block)
          base = options[:base]
          filter = options[:filter]
          limit = options[:limit]

          args = {
            :base => @base,
            :filter => filter,
            :size => limit
          }

          attributes = {}
          execute(:search, args) do |entry|
            entry.attribute_names.each do |name|
              attributes[name] = entry[name]
            end
          end
          attributes
        end

        private

        def execute(method, *args, &block)
          result = @connection.send(method, *args, &block)
          message = nil

          if result.is_a?(Hash)
            message = result[:errorMessage]
            result = result[:resultCode]
          end

          unless result.zero?
            message = [Net::LDAP.result2string(result), message].compact.join(": ")
            raise LdapError, message
          end
        end

        def ensure_port(method)
          if method == :ssl
            URI::LDAPS::DEFAULT_PORT
          else
            URI::LDAP::DEFAULT_PORT
          end
        end

        def prepare_connection(options)
        end

        def ensure_method(method)
            method ||= "plain"
            normalized_method = method.to_s.downcase.to_sym
            return METHOD[normalized_method] if METHOD.has_key?(normalized_method)

            available_methods = METHOD.keys.collect {|m| m.inspect}.join(", ")
            format = "%s is not one of the available connect methods: %s"
            raise ConfigurationError, format % [method.inspect, available_methods]
        end

        def sasl_bind(bind_dn, options={})
          sasl_mechanisms = options[:sasl_mechanisms] || @sasl_mechanisms
            sasl_mechanisms.each do |mechanism|
              begin
                normalized_mechanism = mechanism.downcase.gsub(/-/, '_')
                sasl_bind_setup = "sasl_bind_setup_#{normalized_mechanism}"
                next unless respond_to?(sasl_bind_setup, true)
                initial_credential, challenge_response = send(sasl_bind_setup, bind_dn, options)

                args = {
                  :method => :sasl,
                  :initial_credential => initial_credential,
                  :mechanism => mechanism,
                  :challenge_response => challenge_response,
                }

                info = {
                  :name => "bind: SASL", :dn => bind_dn, :mechanism => mechanism,
                }

                execute(:bind, args)
                return true

              rescue Exception => e
                puts e.message
              end
            end
          false
        end

        def sasl_bind_setup_digest_md5(bind_dn, options)
          initial_credential = ""
          challenge_response = Proc.new do |cred|
            pref = SASL::Preferences.new :digest_uri => "ldap/#{@host}", :username => bind_dn, :has_password? => true, :password => options[:password]||@password
            sasl = SASL.new("DIGEST-MD5", pref)
            response = sasl.receive("challenge", cred)
            response[1]
          end
          [initial_credential, challenge_response]
        end

        def sasl_bind_setup_gss_spnego(bind_dn, options)
          puts options.inspect
          user,psw = [bind_dn, options[:password]||@password]
          raise LdapError.new( "invalid binding information" ) unless (user && psw)

          nego = proc {|challenge|
            t2_msg = Net::NTLM::Message.parse( challenge )
            user, domain = user.split('\\').reverse
            t2_msg.target_name = Net::NTLM::encode_utf16le(domain) if domain
            t3_msg = t2_msg.response( {:user => user, :password => psw}, {:ntlmv2 => true} )
            t3_msg.serialize
          }
          [Net::NTLM::Message::Type1.new.serialize, nego]
        end

        def simple_bind(bind_dn, options={})
          args = {
            :method => :simple,
            :username => bind_dn,
            :password => (options[:password]||@password).to_s,
          }
          begin
            raise AuthenticationError if args[:password] == ""
            execute(:bind, args)
            true
          rescue Exception
            false
          end
        end

        def bind_as_anonymous(options={})
          execute(:bind, {:method => :anonymous})
          true
        end

        def construct_uri(host, port, ssl)
          protocol = ssl ? "ldaps" : "ldap"
          URI.parse("#{protocol}://#{host}:#{port}").to_s
        end

        def target
          return nil if @uri.nil?
          if @with_start_tls
            "#{@uri}(StartTLS)"
          else
            @uri
          end
        end
      end
    end
  end
end
