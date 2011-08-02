#
# Copyright (c) 2007-2008 RightScale Inc
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

# Test
module Aws
    require 'digest/md5'
    require 'pp'
    require 'cgi'
    require 'uri'
    require 'xmlsimple'
    require 'active_support/core_ext'

    class AwsUtils #:nodoc:
        @@digest1   = OpenSSL::Digest::Digest.new("sha1")
        @@digest256 = nil
        if OpenSSL::OPENSSL_VERSION_NUMBER > 0x00908000
            @@digest256 = OpenSSL::Digest::Digest.new("sha256") rescue nil # Some installation may not support sha256
        end

        def self.sign(aws_secret_access_key, auth_string)
            Base64.encode64(OpenSSL::HMAC.digest(@@digest1, aws_secret_access_key, auth_string)).strip
        end


        # Set a timestamp and a signature version
        def self.fix_service_params(service_hash, signature)
            service_hash["Timestamp"] ||= Time.now.utc.strftime("%Y-%m-%dT%H:%M:%S.000Z") unless service_hash["Expires"]
            service_hash["SignatureVersion"] = signature
            service_hash
        end

        # Signature Version 0
        # A deprecated guy (should work till septemper 2009)
        def self.sign_request_v0(aws_secret_access_key, service_hash)
            fix_service_params(service_hash, '0')
            string_to_sign            = "#{service_hash['Action']}#{service_hash['Timestamp'] || service_hash['Expires']}"
            service_hash['Signature'] = AwsUtils::sign(aws_secret_access_key, string_to_sign)
            service_hash.to_a.collect { |key, val| "#{amz_escape(key)}=#{amz_escape(val.to_s)}" }.join("&")
        end

        # Signature Version 1
        # Another deprecated guy (should work till septemper 2009)
        def self.sign_request_v1(aws_secret_access_key, service_hash)
            fix_service_params(service_hash, '1')
            string_to_sign            = service_hash.sort { |a, b| (a[0].to_s.downcase)<=>(b[0].to_s.downcase) }.to_s
            service_hash['Signature'] = AwsUtils::sign(aws_secret_access_key, string_to_sign)
            service_hash.to_a.collect { |key, val| "#{amz_escape(key)}=#{amz_escape(val.to_s)}" }.join("&")
        end

        # Signature Version 2
        # EC2, SQS and SDB requests must be signed by this guy.
        # See:  http://docs.amazonwebservices.com/AmazonSimpleDB/2007-11-07/DeveloperGuide/index.html?REST_RESTAuth.html
        #       http://developer.amazonwebservices.com/connect/entry.jspa?externalID=1928
        def self.sign_request_v2(aws_secret_access_key, service_hash, http_verb, host, uri)
            fix_service_params(service_hash, '2')
            # select a signing method (make an old openssl working with sha1)
            # make 'HmacSHA256' to be a default one
            service_hash['SignatureMethod'] = 'HmacSHA256' unless ['HmacSHA256', 'HmacSHA1'].include?(service_hash['SignatureMethod'])
            service_hash['SignatureMethod'] = 'HmacSHA1' unless @@digest256
            # select a digest
            digest           = (service_hash['SignatureMethod'] == 'HmacSHA256' ? @@digest256 : @@digest1)
            # form string to sign
            canonical_string = service_hash.keys.sort.map do |key|
                "#{amz_escape(key)}=#{amz_escape(service_hash[key])}"
            end.join('&')
            string_to_sign   = "#{http_verb.to_s.upcase}\n#{host.downcase}\n#{uri}\n#{canonical_string}"
            # sign the string
            signature        = escape_sig(Base64.encode64(OpenSSL::HMAC.digest(digest, aws_secret_access_key, string_to_sign)).strip)
            ret              = "#{canonical_string}&Signature=#{signature}"
#            puts 'full=' + ret.inspect
            ret
        end

        HEX         = [
                "%00", "%01", "%02", "%03", "%04", "%05", "%06", "%07",
                "%08", "%09", "%0A", "%0B", "%0C", "%0D", "%0E", "%0F",
                "%10", "%11", "%12", "%13", "%14", "%15", "%16", "%17",
                "%18", "%19", "%1A", "%1B", "%1C", "%1D", "%1E", "%1F",
                "%20", "%21", "%22", "%23", "%24", "%25", "%26", "%27",
                "%28", "%29", "%2A", "%2B", "%2C", "%2D", "%2E", "%2F",
                "%30", "%31", "%32", "%33", "%34", "%35", "%36", "%37",
                "%38", "%39", "%3A", "%3B", "%3C", "%3D", "%3E", "%3F",
                "%40", "%41", "%42", "%43", "%44", "%45", "%46", "%47",
                "%48", "%49", "%4A", "%4B", "%4C", "%4D", "%4E", "%4F",
                "%50", "%51", "%52", "%53", "%54", "%55", "%56", "%57",
                "%58", "%59", "%5A", "%5B", "%5C", "%5D", "%5E", "%5F",
                "%60", "%61", "%62", "%63", "%64", "%65", "%66", "%67",
                "%68", "%69", "%6A", "%6B", "%6C", "%6D", "%6E", "%6F",
                "%70", "%71", "%72", "%73", "%74", "%75", "%76", "%77",
                "%78", "%79", "%7A", "%7B", "%7C", "%7D", "%7E", "%7F",
                "%80", "%81", "%82", "%83", "%84", "%85", "%86", "%87",
                "%88", "%89", "%8A", "%8B", "%8C", "%8D", "%8E", "%8F",
                "%90", "%91", "%92", "%93", "%94", "%95", "%96", "%97",
                "%98", "%99", "%9A", "%9B", "%9C", "%9D", "%9E", "%9F",
                "%A0", "%A1", "%A2", "%A3", "%A4", "%A5", "%A6", "%A7",
                "%A8", "%A9", "%AA", "%AB", "%AC", "%AD", "%AE", "%AF",
                "%B0", "%B1", "%B2", "%B3", "%B4", "%B5", "%B6", "%B7",
                "%B8", "%B9", "%BA", "%BB", "%BC", "%BD", "%BE", "%BF",
                "%C0", "%C1", "%C2", "%C3", "%C4", "%C5", "%C6", "%C7",
                "%C8", "%C9", "%CA", "%CB", "%CC", "%CD", "%CE", "%CF",
                "%D0", "%D1", "%D2", "%D3", "%D4", "%D5", "%D6", "%D7",
                "%D8", "%D9", "%DA", "%DB", "%DC", "%DD", "%DE", "%DF",
                "%E0", "%E1", "%E2", "%E3", "%E4", "%E5", "%E6", "%E7",
                "%E8", "%E9", "%EA", "%EB", "%EC", "%ED", "%EE", "%EF",
                "%F0", "%F1", "%F2", "%F3", "%F4", "%F5", "%F6", "%F7",
                "%F8", "%F9", "%FA", "%FB", "%FC", "%FD", "%FE", "%FF"
        ]
        TO_REMEMBER = 'AZaz09 -_.!~*\'()'
        ASCII       = {} # {'A'=>65, 'Z'=>90, 'a'=>97, 'z'=>122, '0'=>48, '9'=>57, ' '=>32, '-'=>45, '_'=>95, '.'=>}
        TO_REMEMBER.each_char do |c| #unpack("c*").each do |c|
            ASCII[c] = c.unpack("c")[0]
        end
#        puts 'ascii=' + ASCII.inspect

        # Escape a string accordingly Amazon rulles
        # http://docs.amazonwebservices.com/AmazonSimpleDB/2007-11-07/DeveloperGuide/index.html?REST_RESTAuth.html
        def self.amz_escape(param)

            param = param.to_s
#            param = param.force_encoding("UTF-8")

            e     = "x" # escape2(param.to_s)
#            puts 'ESCAPED=' + e.inspect


            #return CGI.escape(param.to_s).gsub("%7E", "~").gsub("+", "%20") # from: http://umlaut.rubyforge.org/svn/trunk/lib/aws_product_sign.rb

            #param.to_s.gsub(/([^a-zA-Z0-9._~-]+)/n) do
            #  '%' + $1.unpack('H2' * $1.size).join('%').upcase
            #end

#            puts 'e in=' + e.inspect
#            converter = Iconv.new('ASCII', 'UTF-8')
#            e = converter.iconv(e) #.unpack('U*').select{ |cp| cp < 127 }.pack('U*')
#            puts 'e out=' + e.inspect

            e2    = CGI.escape(param)
            e2    = e2.gsub("%7E", "~")
            e2    = e2.gsub("+", "%20")
            e2    = e2.gsub("*", "%2A")

#            puts 'E2=' + e2.inspect
#            puts e == e2.to_s

            e2

        end

        def self.escape2(s)
            # home grown
            ret = ""
            s.unpack("U*") do |ch|
#                puts 'ch=' + ch.inspect
                if ASCII['A'] <= ch && ch <= ASCII['Z'] # A to Z
                    ret << ch
                elsif ASCII['a'] <= ch && ch <= ASCII['z'] # a to z
                    ret << ch
                elsif ASCII['0'] <= ch && ch <= ASCII['9'] # 0 to 9
                    ret << ch
                elsif ch == ASCII[' '] # space
                    ret << "%20" # "+"
                elsif ch == ASCII['-'] || ch == ASCII['_'] || ch == ASCII['.'] || ch == ASCII['~']
                    ret << ch
                elsif ch <= 0x007f # other ascii
                    ret << HEX[ch]
                elsif ch <= 0x07FF # non-ascii
                    ret << HEX[0xc0 | (ch >> 6)]
                    ret << HEX[0x80 | (ch & 0x3F)]
                else
                    ret << HEX[0xe0 | (ch >> 12)]
                    ret << HEX[0x80 | ((ch >> 6) & 0x3F)]
                    ret << HEX[0x80 | (ch & 0x3F)]
                end

            end
            ret

        end

        def self.escape_sig(raw)
            e = CGI.escape(raw)
        end

        # From Amazon's SQS Dev Guide, a brief description of how to escape:
        # "URL encode the computed signature and other query parameters as specified in
        # RFC1738, section 2.2. In addition, because the + character is interpreted as a blank space
        # by Sun Java classes that perform URL decoding, make sure to encode the + character
        # although it is not required by RFC1738."
        # Avoid using CGI::escape to escape URIs.
        # CGI::escape will escape characters in the protocol, host, and port
        # sections of the URI.  Only target chars in the query
        # string should be escaped.
        def self.URLencode(raw)
            e = URI.escape(raw)
            e.gsub(/\+/, "%2b")
        end


        def self.allow_only(allowed_keys, params)
            bogus_args = []
            params.keys.each { |p| bogus_args.push(p) unless allowed_keys.include?(p) }
            raise AwsError.new("The following arguments were given but are not legal for the function call #{caller_method}: #{bogus_args.inspect}") if bogus_args.length > 0
        end

        def self.mandatory_arguments(required_args, params)
            rargs = required_args.dup
            params.keys.each { |p| rargs.delete(p) }
            raise AwsError.new("The following mandatory arguments were not provided to #{caller_method}: #{rargs.inspect}") if rargs.length > 0
        end

        def self.caller_method
            caller[1]=~/`(.*?)'/
            $1
        end

    end

    class AwsBenchmarkingBlock #:nodoc:
        attr_accessor :xml, :service

        def initialize
            # Benchmark::Tms instance for service (Ec2, S3, or SQS) access benchmarking.
            @service = Benchmark::Tms.new()
            # Benchmark::Tms instance for XML parsing benchmarking.
            @xml     = Benchmark::Tms.new()
        end
    end

    class AwsNoChange < RuntimeError
    end

    class AwsBase

        # Amazon HTTP Error handling

        # Text, if found in an error message returned by AWS, indicates that this may be a transient
        # error. Transient errors are automatically retried with exponential back-off.
        AMAZON_PROBLEMS   = ['internal service error',
                             'is currently unavailable',
                             'no response from',
                             'Please try again',
                             'InternalError',
                             'ServiceUnavailable', #from SQS docs
                             'Unavailable',
                             'This application is not currently available',
                             'InsufficientInstanceCapacity'
        ]
        @@amazon_problems = AMAZON_PROBLEMS
        # Returns a list of Amazon service responses which are known to be transient problems.
        # We have to re-request if we get any of them, because the problem will probably disappear.
        # By default this method returns the same value as the AMAZON_PROBLEMS const.
        def self.amazon_problems
            @@amazon_problems
        end

        # Sets the list of Amazon side problems.  Use in conjunction with the
        # getter to append problems.
        def self.amazon_problems=(problems_list)
            @@amazon_problems = problems_list
        end

    end

    module AwsBaseInterface
        DEFAULT_SIGNATURE_VERSION = '2'

        @@caching                 = false

        def self.caching
            @@caching
        end

        def self.caching=(caching)
            @@caching = caching
        end

        # Current aws_access_key_id
        attr_reader :aws_access_key_id
        # Last HTTP request object
        attr_reader :last_request
        # Last HTTP response object
        attr_reader :last_response
        # Last AWS errors list (used by AWSErrorHandler)
        attr_accessor :last_errors
        # Last AWS request id (used by AWSErrorHandler)
        attr_accessor :last_request_id
        # Logger object
        attr_accessor :logger
        # Initial params hash
        attr_accessor :params
        # RightHttpConnection instance
        attr_reader :connection
        # Cache
        attr_reader :cache
        # Signature version (all services except s3)
        attr_reader :signature_version

        def init(service_info, aws_access_key_id, aws_secret_access_key, params={}) #:nodoc:
            @params = params
            raise AwsError.new("AWS access keys are required to operate on #{service_info[:name]}") \
 if aws_access_key_id.blank? || aws_secret_access_key.blank?
            @aws_access_key_id     = aws_access_key_id
            @aws_secret_access_key = aws_secret_access_key
            # if the endpoint was explicitly defined - then use it
            if @params[:endpoint_url]
                @params[:server]   = URI.parse(@params[:endpoint_url]).host
                @params[:port]     = URI.parse(@params[:endpoint_url]).port
                @params[:service]  = URI.parse(@params[:endpoint_url]).path
                @params[:protocol] = URI.parse(@params[:endpoint_url]).scheme
                @params[:region]   = nil
            else
                @params[:server] ||= service_info[:default_host]
                @params[:server] = "#{@params[:region]}.#{@params[:server]}" if @params[:region]
                @params[:port]        ||= service_info[:default_port]
                @params[:service]     ||= service_info[:default_service]
                @params[:protocol]    ||= service_info[:default_protocol]
                @params[:api_version] ||= service_info[:api_version]
            end
            if !@params[:multi_thread].nil? && @params[:connection_mode].nil? # user defined this
                @params[:connection_mode] = @params[:multi_thread] ? :per_thread : :single
            end
#      @params[:multi_thread] ||= defined?(AWS_DAEMON)
            @params[:connection_mode] ||= :default
            @params[:connection_mode] = :per_request if @params[:connection_mode] == :default
            @logger = @params[:logger]
            @logger = Rails.logger if !@logger && defined?(Rails) && defined?(Rails.logger)
            @logger = ::Rails.logger if !@logger && defined?(::Rails.logger)
            @logger = Logger.new(STDOUT) if !@logger
            @logger.info "New #{self.class.name} using #{@params[:connection_mode].to_s}-connection mode"
            @error_handler     = nil
            @cache             = {}
            @signature_version = (params[:signature_version] || DEFAULT_SIGNATURE_VERSION).to_s
        end

        def signed_service_params(aws_secret_access_key, service_hash, http_verb=nil, host=nil, service=nil)
            case signature_version.to_s
                when '0' then
                    AwsUtils::sign_request_v0(aws_secret_access_key, service_hash)
                when '1' then
                    AwsUtils::sign_request_v1(aws_secret_access_key, service_hash)
                when '2' then
                    AwsUtils::sign_request_v2(aws_secret_access_key, service_hash, http_verb, host, service)
                else
                    raise AwsError.new("Unknown signature version (#{signature_version.to_s}) requested")
            end
        end


        def generate_request(action, params={})
            generate_request2(@aws_access_key_id, @aws_secret_access_key, action, @params[:api_version], @params, params)
        end

        # FROM SDB
        def generate_request2(aws_access_key, aws_secret_key, action, api_version, lib_params, user_params={}, options={}) #:nodoc:
            # remove empty params from request
            user_params.delete_if { |key, value| value.nil? }
#            user_params.each_pair do |k,v|
#                user_params[k] = v.force_encoding("UTF-8")
#            end
            #params_string  = params.to_a.collect{|key,val| key + "=#{CGI::escape(val.to_s)}" }.join("&")
            # prepare service data
            service      = lib_params[:service]
#      puts 'service=' + service.to_s
            service_hash = {"Action"         => action,
                            "AWSAccessKeyId" => aws_access_key}
            service_hash.update("Version" => api_version) if api_version
            service_hash.update(user_params)
            service_params = signed_service_params(aws_secret_key, service_hash, :get, lib_params[:server], lib_params[:service])
            #
            # use POST method if the length of the query string is too large
            # see http://docs.amazonwebservices.com/AmazonSimpleDB/2007-11-07/DeveloperGuide/MakingRESTRequests.html
            if service_params.size > 2000
                if signature_version == '2'
                    # resign the request because HTTP verb is included into signature
                    service_params = signed_service_params(aws_secret_key, service_hash, :post, lib_params[:server], service)
                end
                request                 = Net::HTTP::Post.new(service)
                request.body            = service_params
                request['Content-Type'] = 'application/x-www-form-urlencoded; charset=utf-8'
            else
                request = Net::HTTP::Get.new("#{service}?#{service_params}")
            end

            #puts "\n\n --------------- QUERY REQUEST TO AWS -------------- \n\n"
            #puts "#{@params[:service]}?#{service_params}\n\n"

            # prepare output hash
            {:request  => request,
             :server   => lib_params[:server],
             :port     => lib_params[:port],
             :protocol => lib_params[:protocol]}
        end

        def get_conn(connection_name, lib_params, logger)
#            thread = lib_params[:multi_thread] ? Thread.current : Thread.main
#            thread[connection_name] ||= Rightscale::HttpConnection.new(:exception => Aws::AwsError, :logger => logger)
#            conn = thread[connection_name]
#            return conn
            http_conn = nil
            conn_mode = lib_params[:connection_mode]
            
            # Slice all parameters accepted by Rightscale::HttpConnection#new
            params = lib_params.slice(
              :user_agent, :ca_file, :http_connection_retry_count, :http_connection_open_timeout,
              :http_connection_read_timeout, :http_connection_retry_delay
            )
            params.merge!(:exception => AwsError, :logger => logger)
            
            if conn_mode == :per_request
                http_conn = Rightscale::HttpConnection.new(params)

            elsif conn_mode == :per_thread || conn_mode == :single
                thread                  = conn_mode == :per_thread ? Thread.current : Thread.main
                thread[connection_name] ||= Rightscale::HttpConnection.new(params)
                http_conn               = thread[connection_name]
#                ret = request_info_impl(http_conn, bench, request, parser, &block)
            end
            return http_conn

        end

        def close_conn(conn_name)
            conn_mode = @params[:connection_mode]
            if conn_mode == :per_thread || conn_mode == :single
                thread = conn_mode == :per_thread ? Thread.current : Thread.main
                if !thread[conn_name].nil?
                    thread[conn_name].finish
                    thread[conn_name] = nil
                end
            end
        end

#
#        def request_info2(request, parser, lib_params, connection_name, logger, bench)
#            t = get_conn(connection_name, lib_params, logger)
#            request_info_impl(t, bench, request, parser)
#        end

        # Sends request to Amazon and parses the response
        # Raises AwsError if any banana happened
        def request_info2(request, parser, lib_params, connection_name, logger, bench, options={}, &block) #:nodoc:
            ret       = nil
#            puts 'OPTIONS=' + options.inspect
            http_conn = get_conn(connection_name, lib_params, logger)
            begin
                retry_count = 1
                count       = 0
                while count <= retry_count
                    puts 'RETRYING QUERY due to QueryTimeout...' if count > 0
                    begin
                        ret = request_info_impl(http_conn, bench, request, parser, options, &block)
                        break
                    rescue Aws::AwsError => ex
                        if !ex.include?(/QueryTimeout/) || count == retry_count
                            raise ex
                        end
                    end
                    count += 1
                end
            ensure
                http_conn.finish if http_conn && lib_params[:connection_mode] == :per_request
            end
            ret
        end


        # This is the direction we should head instead of writing our own parsers for everything, much simpler
        # params:
        #  - :group_tags => hash of indirection to eliminate, see: http://xml-simple.rubyforge.org/
        #  - :force_array => true for all or an array of tag names to force
        #  - :pull_out_array => an array of levels to dig into when generating return value (see rds.rb for example)
        def request_info_xml_simple(connection_name, lib_params, request, logger, params = {})

            @connection = get_conn(connection_name, lib_params, logger)
            begin
                @last_request  = request[:request]
                @last_response = nil

                response       = @connection.request(request)
                #       puts "response=" + response.body
#            benchblock.service.add!{ response = @connection.request(request) }
                # check response for errors...
                @last_response = response
                if response.is_a?(Net::HTTPSuccess)
                    @error_handler     = nil
#                benchblock.xml.add! { parser.parse(response) }
#                return parser.result
                    force_array        = params[:force_array] || false
                    # Force_array and group_tags don't work nice together so going to force array manually
                    xml_simple_options = {"KeyToSymbol"=>false, 'ForceArray' => false}
                    xml_simple_options["GroupTags"] = params[:group_tags] if params[:group_tags]

#                { 'GroupTags' => { 'searchpath' => 'dir' }
#                'ForceArray' => %r(_list$)
                    parsed = XmlSimple.xml_in(response.body, xml_simple_options)
                    # todo: we may want to consider stripping off a couple of layers when doing this, for instance:
                    # <DescribeDBInstancesResponse xmlns="http://rds.amazonaws.com/admin/2009-10-16/">
                    #  <DescribeDBInstancesResult>
                    #    <DBInstances>
                    # <DBInstance>....
                    # Strip it off and only return an array or hash of <DBInstance>'s (hash by identifier).
                    # would have to be able to make the RequestId available somehow though, perhaps some special array subclass which included that?
                    unless force_array.is_a? Array
                        force_array = []
                    end
                    parsed = symbolize(parsed, force_array)
#                puts 'parsed=' + parsed.inspect
                    if params[:pull_out_array]
                        ret        = Aws::AwsResponseArray.new(parsed[:response_metadata])
                        level_hash = parsed
                        params[:pull_out_array].each do |x|
                            level_hash = level_hash[x]
                        end
                        if level_hash.is_a? Hash # When there's only one
                            ret << level_hash
                        else # should be array
#                            puts 'level_hash=' + level_hash.inspect
                            level_hash.each do |x|
                                ret << x
                            end
                        end
                    elsif params[:pull_out_single]
                        # returns a single object
                        ret        = AwsResponseObjectHash.new(parsed[:response_metadata])
                        level_hash = parsed
                        params[:pull_out_single].each do |x|
                            level_hash = level_hash[x]
                        end
                        ret.merge!(level_hash)
                    else
                        ret = parsed
                    end
                    return ret

                else
                    @error_handler = AWSErrorHandler.new(self, nil, :errors_list => self.class.amazon_problems) unless @error_handler
                    check_result = @error_handler.check(request)
                    if check_result
                        @error_handler = nil
                        return check_result
                    end
                    request_text_data = "#{request[:server]}:#{request[:port]}#{request[:request].path}"
                    raise AwsError2.new(@last_response.code, @last_request_id, request_text_data, @last_response.body)
                end
            ensure
                @connection.finish if @connection && lib_params[:connection_mode] == :per_request
            end

        end

        def symbolize(hash, force_array)
            ret = {}
            hash.keys.each do |key|
                val = hash[key]
                if val.is_a? Hash
                    val = symbolize(val, force_array)
                    if force_array.include? key
                        val = [val]
                    end
                elsif val.is_a? Array
                    val = val.collect { |x| symbolize(x, force_array) }
                end
                ret[key.underscore.to_sym] = val
            end
            ret
        end

        # Returns +true+ if the describe_xxx responses are being cached
        def caching?
            @params.key?(:cache) ? @params[:cache] : @@caching
        end

        # Check if the aws function response hits the cache or not.
        # If the cache hits:
        # - raises an +AwsNoChange+ exception if +do_raise+ == +:raise+.
        # - returnes parsed response from the cache if it exists or +true+ otherwise.
        # If the cache miss or the caching is off then returns +false+.
        def cache_hits?(function, response, do_raise=:raise)
            result = false
            if caching?
                function     = function.to_sym
                # get rid of requestId (this bad boy was added for API 2008-08-08+ and it is uniq for every response)
                response     = response.sub(%r{<requestId>.+?</requestId>}, '')
                response_md5 =Digest::MD5.hexdigest(response).to_s
                # check for changes
                unless @cache[function] && @cache[function][:response_md5] == response_md5
                    # well, the response is new, reset cache data
                    update_cache(function, {:response_md5 => response_md5,
                                            :timestamp    => Time.now,
                                            :hits         => 0,
                                            :parsed       => nil})
                else
                    # aha, cache hits, update the data and throw an exception if needed
                    @cache[function][:hits] += 1
                    if do_raise == :raise
                        raise(AwsNoChange, "Cache hit: #{function} response has not changed since "+
                                "#{@cache[function][:timestamp].strftime('%Y-%m-%d %H:%M:%S')}, "+
                                "hits: #{@cache[function][:hits]}.")
                    else
                        result = @cache[function][:parsed] || true
                    end
                end
            end
            result
        end

        def update_cache(function, hash)
            (@cache[function.to_sym] ||= {}).merge!(hash) if caching?
        end

        def on_exception(options={:raise=>true, :log=>true}) # :nodoc:
            raise if $!.is_a?(AwsNoChange)
            AwsError::on_aws_exception(self, options)
        end

        # Return +true+ if this instance works in multi_thread mode and +false+ otherwise.
        def multi_thread
            @params[:multi_thread]
        end


        def request_info_impl(connection, benchblock, request, parser, options={}, &block) #:nodoc:
            @connection    = connection
            @last_request  = request[:request]
            @last_response = nil
            response       =nil
            blockexception = nil

#             puts 'OPTIONS2=' + options.inspect

            if (block != nil)
                # TRB 9/17/07 Careful - because we are passing in blocks, we get a situation where
                # an exception may get thrown in the block body (which is high-level
                # code either here or in the application) but gets caught in the
                # low-level code of HttpConnection.  The solution is not to let any
                # exception escape the block that we pass to HttpConnection::request.
                # Exceptions can originate from code directly in the block, or from user
                # code called in the other block which is passed to response.read_body.
                benchblock.service.add! do
                    responsehdr = @connection.request(request) do |response|
                        #########
                        begin
                            @last_response = response
                            if response.is_a?(Net::HTTPSuccess)
                                @error_handler = nil
                                response.read_body(&block)
                            else
                                @error_handler = AWSErrorHandler.new(self, parser, :errors_list => self.class.amazon_problems) unless @error_handler
                                check_result = @error_handler.check(request, options)
                                if check_result
                                    @error_handler = nil
                                    return check_result
                                end
                                request_text_data = "#{request[:server]}:#{request[:port]}#{request[:request].path}"
                                raise AwsError.new(@last_errors, @last_response.code, @last_request_id, request_text_data)
                            end
                        rescue Exception => e
                            blockexception = e
                        end
                    end
                    #########

                    #OK, now we are out of the block passed to the lower level
                    if (blockexception)
                        raise blockexception
                    end
                    benchblock.xml.add! do
                        parser.parse(responsehdr)
                    end
                    return parser.result
                end
            else
                benchblock.service.add! { response = @connection.request(request) }
                # check response for errors...
                @last_response = response
                if response.is_a?(Net::HTTPSuccess)
                    @error_handler = nil
                    benchblock.xml.add! { parser.parse(response) }
                    return parser.result
                else
                    @error_handler = AWSErrorHandler.new(self, parser, :errors_list => self.class.amazon_problems) unless @error_handler
                    check_result = @error_handler.check(request, options)
                    if check_result
                        @error_handler = nil
                        return check_result
                    end
                    request_text_data = "#{request[:server]}:#{request[:port]}#{request[:request].path}"
                    raise AwsError.new(@last_errors, @last_response.code, @last_request_id, request_text_data)
                end
            end
        rescue
            @error_handler = nil
            raise
        end

        def request_cache_or_info(method, link, parser_class, benchblock, use_cache=true) #:nodoc:
            # We do not want to break the logic of parsing hence will use a dummy parser to process all the standard
            # steps (errors checking etc). The dummy parser does nothig - just returns back the params it received.
            # If the caching is enabled and hit then throw  AwsNoChange.
            # P.S. caching works for the whole images list only! (when the list param is blank)
            # check cache
            response, params = request_info(link, RightDummyParser.new)
            cache_hits?(method.to_sym, response.body) if use_cache
            parser = parser_class.new(:logger => @logger)
            benchblock.xml.add! { parser.parse(response, params) }
            result = block_given? ? yield(parser) : parser.result
            # update parsed data
            update_cache(method.to_sym, :parsed => result) if use_cache
            result
        end

        # Returns Amazons request ID for the latest request
        def last_request_id
            @last_response && @last_response.body.to_s[%r{<requestId>(.+?)</requestId>}] && $1
        end

        def hash_params(prefix, list) #:nodoc:
            groups = {}
            list.each_index { |i| groups.update("#{prefix}.#{i+1}"=>list[i]) } if list
            return groups
        end

    end


# Exception class to signal any Amazon errors. All errors occuring during calls to Amazon's
# web services raise this type of error.
# Attribute inherited by RuntimeError:
#  message    - the text of the error, generally as returned by AWS in its XML response.
    class AwsError < RuntimeError

        # either an array of errors where each item is itself an array of [code, message]),
        # or an error string if the error was raised manually, as in <tt>AwsError.new('err_text')</tt>
        attr_reader :errors

        # Request id (if exists)
        attr_reader :request_id

        # Response HTTP error code
        attr_reader :http_code

        # Raw request text data to AWS
        attr_reader :request_data

        attr_reader :response

        def initialize(errors=nil, http_code=nil, request_id=nil, request_data=nil, response=nil)
            @errors       = errors
            @request_id   = request_id
            @http_code    = http_code
            @request_data = request_data
            @response     = response
            msg           = @errors.is_a?(Array) ? @errors.map { |code, msg| "#{code}: #{msg}" }.join("; ") : @errors.to_s
            msg += "\nREQUEST=#{@request_data} " unless @request_data.nil?
            msg += "\nREQUEST ID=#{@request_id} " unless @request_id.nil?
            super(msg)
        end

        # Does any of the error messages include the regexp +pattern+?
        # Used to determine whether to retry request.
        def include?(pattern)
            if @errors.is_a?(Array)
                @errors.each { |code, msg| return true if code =~ pattern }
            else
                return true if @errors_str =~ pattern
            end
            false
        end

        # Generic handler for AwsErrors. +aws+ is the Aws::S3, Aws::EC2, or Aws::SQS
        # object that caused the exception (it must provide last_request and last_response). Supported
        # boolean options are:
        # * <tt>:log</tt> print a message into the log using aws.logger to access the Logger
        # * <tt>:puts</tt> do a "puts" of the error
        # * <tt>:raise</tt> re-raise the error after logging
        def self.on_aws_exception(aws, options={:raise=>true, :log=>true})
            # Only log & notify if not user error
            if !options[:raise] || system_error?($!)
                error_text = "#{$!.inspect}\n#{$@}.join('\n')}"
                puts error_text if options[:puts]
                # Log the error
                if options[:log]
                    request   = aws.last_request ? aws.last_request.path : '-none-'
                    response  = aws.last_response ? "#{aws.last_response.code} -- #{aws.last_response.message} -- #{aws.last_response.body}" : '-none-'
                    @response = response
                    aws.logger.error error_text
                    aws.logger.error "Request was:  #{request}"
                    aws.logger.error "Response was: #{response}"
                end
            end
            raise if options[:raise] # re-raise an exception
            return nil
        end

        # True if e is an AWS system error, i.e. something that is for sure not the caller's fault.
        # Used to force logging.
        def self.system_error?(e)
            !e.is_a?(self) || e.message =~ /InternalError|InsufficientInstanceCapacity|Unavailable/
        end

    end

# Simplified version
    class AwsError2 < RuntimeError
        # Request id (if exists)
        attr_reader :request_id

        # Response HTTP error code
        attr_reader :http_code

        # Raw request text data to AWS
        attr_reader :request_data

        attr_reader :response

        attr_reader :errors

        def initialize(http_code=nil, request_id=nil, request_data=nil, response=nil)

            @request_id   = request_id
            @http_code    = http_code
            @request_data = request_data
            @response     = response
#            puts '@response=' + @response.inspect

            if @response
                ref = XmlSimple.xml_in(@response, {"ForceArray"=>false})
#                puts "refxml=" + ref.inspect
                msg = "#{ref['Error']['Code']}: #{ref['Error']['Message']}"
            else
                msg = "#{@http_code}: REQUEST(#{@request_data})"
            end
            msg += "\nREQUEST ID=#{@request_id} " unless @request_id.nil?
            super(msg)
        end


    end


    class AWSErrorHandler
        # 0-100 (%)
        DEFAULT_CLOSE_ON_4XX_PROBABILITY = 10

        @@reiteration_start_delay        = 0.2

        def self.reiteration_start_delay
            @@reiteration_start_delay
        end

        def self.reiteration_start_delay=(reiteration_start_delay)
            @@reiteration_start_delay = reiteration_start_delay
        end

        @@reiteration_time = 5

        def self.reiteration_time
            @@reiteration_time
        end

        def self.reiteration_time=(reiteration_time)
            @@reiteration_time = reiteration_time
        end

        @@close_on_error = true

        def self.close_on_error
            @@close_on_error
        end

        def self.close_on_error=(close_on_error)
            @@close_on_error = close_on_error
        end

        @@close_on_4xx_probability = DEFAULT_CLOSE_ON_4XX_PROBABILITY

        def self.close_on_4xx_probability
            @@close_on_4xx_probability
        end

        def self.close_on_4xx_probability=(close_on_4xx_probability)
            @@close_on_4xx_probability = close_on_4xx_probability
        end

        # params:
        #  :reiteration_time
        #  :errors_list
        #  :close_on_error           = true | false
        #  :close_on_4xx_probability = 1-100
        def initialize(aws, parser, params={}) #:nodoc:
            @aws                      = aws # Link to RightEc2 | RightSqs | RightS3 instance
            @parser                   = parser # parser to parse Amazon response
            @started_at               = Time.now
            @stop_at                  = @started_at + (params[:reiteration_time] || @@reiteration_time)
            @errors_list              = params[:errors_list] || []
            @reiteration_delay        = @@reiteration_start_delay
            @retries                  = 0
            # close current HTTP(S) connection on 5xx, errors from list and 4xx errors
            @close_on_error           = params[:close_on_error].nil? ? @@close_on_error : params[:close_on_error]
            @close_on_4xx_probability = params[:close_on_4xx_probability] || @@close_on_4xx_probability
        end

        # Returns false if
        def check(request, options={}) #:nodoc:
            result            = false
            error_found       = false
            redirect_detected = false
            error_match       = nil
            last_errors_text  = ''
            response          = @aws.last_response
            # log error
            request_text_data = "#{request[:server]}:#{request[:port]}#{request[:request].path}"
            # is this a redirect?
            # yes!
            if response.is_a?(Net::HTTPRedirection)
                redirect_detected = true
            else
                # no, it's an error ...
                @aws.logger.warn("##### #{@aws.class.name} returned an error: #{response.code} #{response.message}\n#{response.body} #####")
                @aws.logger.warn("##### #{@aws.class.name} request: #{request_text_data} ####")
            end
            # Check response body: if it is an Amazon XML document or not:
            if redirect_detected || (response.body && response.body[/<\?xml/]) # ... it is a xml document
                @aws.class.bench_xml.add! do
                    error_parser = RightErrorResponseParser.new
                    error_parser.parse(response)
                    @aws.last_errors     = error_parser.errors
                    @aws.last_request_id = error_parser.requestID
                    last_errors_text     = @aws.last_errors.flatten.join("\n")
                    # on redirect :
                    if redirect_detected
                        location = response['location']
                        # ... log information and ...
                        @aws.logger.info("##### #{@aws.class.name} redirect requested: #{response.code} #{response.message} #####")
                        @aws.logger.info("##### New location: #{location} #####")
                        # ... fix the connection data
                        request[:server]   = URI.parse(location).host
                        request[:protocol] = URI.parse(location).scheme
                        request[:port]     = URI.parse(location).port
                    end
                end
            else # ... it is not a xml document(probably just a html page?)
                @aws.last_errors     = [[response.code, "#{response.message} (#{request_text_data})"]]
                @aws.last_request_id = '-undefined-'
                last_errors_text     = response.message
            end
            # now - check the error
            unless redirect_detected
                @errors_list.each do |error_to_find|
                    if last_errors_text[/#{error_to_find}/i]
                        error_found = true
                        error_match = error_to_find
                        @aws.logger.warn("##### Retry is needed, error pattern match: #{error_to_find} #####")
                        break
                    end
                end
            end
            # check the time has gone from the first error come
            if redirect_detected || error_found
                # Close the connection to the server and recreate a new one.
                # It may have a chance that one server is a semi-down and reconnection
                # will help us to connect to the other server
                if !redirect_detected && @close_on_error
                    @aws.connection.finish "#{self.class.name}: error match to pattern '#{error_match}'"
                end
# puts 'OPTIONS3=' + options.inspect
                if options[:retries].nil? || @retries < options[:retries]
                    if (Time.now < @stop_at)
                        @retries += 1
                        unless redirect_detected
                            @aws.logger.warn("##### Retry ##{@retries} is being performed. Sleeping for #{@reiteration_delay} sec. Whole time: #{Time.now-@started_at} sec ####")
                            sleep @reiteration_delay
                            @reiteration_delay *= 2

                            # Always make sure that the fp is set to point to the beginning(?)
                            # of the File/IO. TODO: it assumes that offset is 0, which is bad.
                            if (request[:request].body_stream && request[:request].body_stream.respond_to?(:pos))
                                begin
                                    request[:request].body_stream.pos = 0
                                rescue Exception => e
                                    @logger.warn("Retry may fail due to unable to reset the file pointer" +
                                                         " -- #{self.class.name} : #{e.inspect}")
                                end
                            end
                        else
                            @aws.logger.info("##### Retry ##{@retries} is being performed due to a redirect.  ####")
                        end
                        result = @aws.request_info(request, @parser, options)
                    else
                        @aws.logger.warn("##### Ooops, time is over... ####")
                    end
                else
                    @aws.logger.info("##### Stopped retrying because retries=#{@retries} and max=#{options[:retries]}  ####")
                end
                # aha, this is unhandled error:
            elsif @close_on_error
                # Is this a 5xx error ?
                if @aws.last_response.code.to_s[/^5\d\d$/]
                    @aws.connection.finish "#{self.class.name}: code: #{@aws.last_response.code}: '#{@aws.last_response.message}'"
                    # Is this a 4xx error ?
                elsif @aws.last_response.code.to_s[/^4\d\d$/] && @close_on_4xx_probability > rand(100)
                    @aws.connection.finish "#{self.class.name}: code: #{@aws.last_response.code}: '#{@aws.last_response.message}', " +
                                                   "probability: #{@close_on_4xx_probability}%"
                end
            end
            result
        end

    end


#-----------------------------------------------------------------

    class RightSaxParserCallback #:nodoc:
        def self.include_callback
            include XML::SaxParser::Callbacks
        end

        def initialize(right_aws_parser)
            @right_aws_parser = right_aws_parser
        end

        def on_start_element(name, attr_hash)
            @right_aws_parser.tag_start(name, attr_hash)
        end

        def on_characters(chars)
            @right_aws_parser.text(chars)
        end

        def on_end_element(name)
            @right_aws_parser.tag_end(name)
        end

        def on_start_document;
        end

        def on_comment(msg)
            ;
        end

        def on_processing_instruction(target, data)
            ;
        end

        def on_cdata_block(cdata)
            ;
        end

        def on_end_document;
        end
    end

    class AwsParser #:nodoc:
        # default parsing library
        DEFAULT_XML_LIBRARY  = 'rexml'
        # a list of supported parsers
        @@supported_xml_libs = [DEFAULT_XML_LIBRARY, 'libxml']

        @@xml_lib            = DEFAULT_XML_LIBRARY # xml library name: 'rexml' | 'libxml'
        def self.xml_lib
            @@xml_lib
        end

        def self.xml_lib=(new_lib_name)
            @@xml_lib = new_lib_name
        end

        attr_accessor :result
        attr_reader :xmlpath
        attr_accessor :xml_lib

        def initialize(params={})
            @xmlpath = ''
            @result  = false
            @text    = ''
            @xml_lib = params[:xml_lib] || @@xml_lib
            @logger  = params[:logger]
            reset
        end

        def tag_start(name, attributes)
            @text = ''
            tagstart(name, attributes)
            @xmlpath += @xmlpath.empty? ? name : "/#{name}"
        end

        def tag_end(name)
            if @xmlpath =~ /^(.*?)\/?#{name}$/
                @xmlpath = $1
            end
            tagend(name)
        end

        def text(text)
            @text += text
            tagtext(text)
        end

        # Parser method.
        # Params:
        #   xml_text         - xml message text(String) or Net:HTTPxxx instance (response)
        #   params[:xml_lib] - library name: 'rexml' | 'libxml'
        def parse(xml_text, params={})
            # Get response body
            unless xml_text.is_a?(String)
                xml_text = xml_text.body.respond_to?(:force_encoding) ? xml_text.body.force_encoding("UTF-8") : xml_text.body
            end

            @xml_lib = params[:xml_lib] || @xml_lib
            # check that we had no problems with this library otherwise use default
            @xml_lib = DEFAULT_XML_LIBRARY unless @@supported_xml_libs.include?(@xml_lib)
            # load xml library
            if @xml_lib=='libxml' && !defined?(XML::SaxParser)
                begin
                    require 'xml/libxml'
                    # is it new ? - Setup SaxParserCallback
                    if XML::Parser::VERSION >= '0.5.1.0'
                        RightSaxParserCallback.include_callback
                    end
                rescue LoadError => e
                    @@supported_xml_libs.delete(@xml_lib)
                    @xml_lib = DEFAULT_XML_LIBRARY
                    if @logger
                        @logger.error e.inspect
                        @logger.error e.backtrace
                        @logger.info "Can not load 'libxml' library. '#{DEFAULT_XML_LIBRARY}' is used for parsing."
                    end
                end
            end
            # Parse the xml text
            case @xml_lib
                when 'libxml'
                    xml = XML::SaxParser.string(xml_text)
                    # check libxml-ruby version
                    if XML::Parser::VERSION >= '0.5.1.0'
                        xml.callbacks = RightSaxParserCallback.new(self)
                    else
                        xml.on_start_element { |name, attr_hash| self.tag_start(name, attr_hash) }
                        xml.on_characters { |text| self.text(text) }
                        xml.on_end_element { |name| self.tag_end(name) }
                    end
                    xml.parse
                else
                    REXML::Document.parse_stream(xml_text, self)
            end
        end

        # Parser must have a lots of methods
        # (see /usr/lib/ruby/1.8/rexml/parsers/streamparser.rb)
        # We dont need most of them in AwsParser and method_missing helps us
        # to skip their definition
        def method_missing(method, *params)
            # if the method is one of known - just skip it ...
            return if [:comment, :attlistdecl, :notationdecl, :elementdecl,
                       :entitydecl, :cdata, :xmldecl, :attlistdecl, :instruction,
                       :doctype].include?(method)
            # ... else - call super to raise an exception
            super(method, params)
        end

        # the functions to be overriden by children (if nessesery)
        def reset;
        end

        def tagstart(name, attributes)
            ;
        end

        def tagend(name)
            ;
        end

        def tagtext(text)
            ;
        end
    end

#-----------------------------------------------------------------
#      PARSERS: Errors
#-----------------------------------------------------------------

#<Error>
#  <Code>TemporaryRedirect</Code>
#  <Message>Please re-send this request to the specified temporary endpoint. Continue to use the original request endpoint for future requests.</Message>
#  <RequestId>FD8D5026D1C5ABA3</RequestId>
#  <Endpoint>bucket-for-k.s3-external-3.amazonaws.com</Endpoint>
#  <HostId>ItJy8xPFPli1fq/JR3DzQd3iDvFCRqi1LTRmunEdM1Uf6ZtW2r2kfGPWhRE1vtaU</HostId>
#  <Bucket>bucket-for-k</Bucket>
#</Error>

    class RightErrorResponseParser < AwsParser #:nodoc:
        attr_accessor :errors # array of hashes: error/message
        attr_accessor :requestID
#    attr_accessor :endpoint, :host_id, :bucket
        def tagend(name)
            case name
                when 'RequestID';
                    @requestID = @text
                when 'Code';
                    @code = @text
                when 'Message';
                    @message = @text
#       when 'Endpoint'  ; @endpoint  = @text
#       when 'HostId'    ; @host_id   = @text
#       when 'Bucket'    ; @bucket    = @text
                when 'Error';
                    @errors << [@code, @message]
            end
        end

        def reset
            @errors = []
        end
    end

# Dummy parser - does nothing
# Returns the original params back
    class RightDummyParser # :nodoc:
        attr_accessor :result

        def parse(response, params={})
            @result = [response, params]
        end
    end

    class RightHttp2xxParser < AwsParser # :nodoc:
        def parse(response)
            @result = response.is_a?(Net::HTTPSuccess)
        end
    end

end

