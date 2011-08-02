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

module Aws

    class S3Interface < AwsBase

        USE_100_CONTINUE_PUT_SIZE = 1_000_000

        include AwsBaseInterface

        DEFAULT_HOST           = 's3.amazonaws.com'
        DEFAULT_PORT           = 443
        DEFAULT_PROTOCOL       = 'https'
        DEFAULT_SERVICE        = '/'
        REQUEST_TTL            = 30
        DEFAULT_EXPIRES_AFTER  = 1 * 24 * 60 * 60 # One day's worth of seconds
        ONE_YEAR_IN_SECONDS    = 365 * 24 * 60 * 60
        AMAZON_HEADER_PREFIX   = 'x-amz-'
        AMAZON_METADATA_PREFIX = 'x-amz-meta-'

        @@bench                = AwsBenchmarkingBlock.new

        def self.bench_xml
            @@bench.xml
        end

        def self.bench_s3
            @@bench.service
        end


        # Creates new RightS3 instance.
        #
        #  s3 = Aws::S3Interface.new('1E3GDYEOGFJPIT7XXXXXX','hgTHt68JY07JKUY08ftHYtERkjgtfERn57XXXXXX', {:multi_thread => true, :logger => Logger.new('/tmp/x.log')}) #=> #<Aws::S3Interface:0xb7b3c27c>
        #
        # Params is a hash:
        #
        #    {:server       => 's3.amazonaws.com'   # Amazon service host: 's3.amazonaws.com'(default)
        #     :port         => 443                  # Amazon service port: 80 or 443(default)
        #     :protocol     => 'https'              # Amazon service protocol: 'http' or 'https'(default)
        #     :connection_mode  => :default         # options are
        #                                                  :default (will use best known safe (as in won't need explicit close) option, may change in the future)
        #                                                  :per_request (opens and closes a connection on every request)
        #                                                  :single (one thread across entire app)
        #                                                  :per_thread (one connection per thread)
        #     :logger       => Logger Object}       # Logger instance: logs to STDOUT if omitted }
        #
        def initialize(aws_access_key_id=nil, aws_secret_access_key=nil, params={})
            init({:name             => 'S3',
                  :default_host     => ENV['S3_URL'] ? URI.parse(ENV['S3_URL']).host : DEFAULT_HOST,
                  :default_port     => ENV['S3_URL'] ? URI.parse(ENV['S3_URL']).port : DEFAULT_PORT,
                  :default_service  => ENV['S3_URL'] ? URI.parse(ENV['S3_URL']).path : DEFAULT_SERVICE,
                  :default_protocol => ENV['S3_URL'] ? URI.parse(ENV['S3_URL']).scheme : DEFAULT_PROTOCOL},
                 aws_access_key_id || ENV['AWS_ACCESS_KEY_ID'],
                 aws_secret_access_key || ENV['AWS_SECRET_ACCESS_KEY'],
                 params)
        end


        def close_connection
            close_conn :s3_connection
        end

        #-----------------------------------------------------------------
        #      Requests
        #-----------------------------------------------------------------
        # Produces canonical string for signing.
        def canonical_string(method, path, headers={}, expires=nil) # :nodoc:
            s3_headers = {}
            headers.each do |key, value|
                key = key.downcase
                s3_headers[key] = value.join("").strip if key[/^#{AMAZON_HEADER_PREFIX}|^content-md5$|^content-type$|^date$/o]
            end
            s3_headers['content-type'] ||= ''
            s3_headers['content-md5']  ||= ''
            s3_headers['date'] = '' if s3_headers.has_key? 'x-amz-date'
            s3_headers['date'] = expires if expires
            # prepare output string
            out_string = "#{method}\n"
            s3_headers.sort { |a, b| a[0] <=> b[0] }.each do |key, value|
                out_string << (key[/^#{AMAZON_HEADER_PREFIX}/o] ? "#{key}:#{value}\n" : "#{value}\n")
            end
            # ignore everything after the question mark...
            out_string << path.gsub(/\?.*$/, '')
            # ...unless there is an acl or torrent parameter
            out_string << '?acl' if path[/[&?]acl($|&|=)/]
            out_string << '?policy' if path[/[&?]policy($|&|=)/]
            out_string << '?torrent' if path[/[&?]torrent($|&|=)/]
            out_string << '?location' if path[/[&?]location($|&|=)/]
            out_string << '?logging' if path[/[&?]logging($|&|=)/] # this one is beta, no support for now
            out_string
        end

        # http://docs.amazonwebservices.com/AmazonS3/2006-03-01/index.html?BucketRestrictions.html
        def is_dns_bucket?(bucket_name)
            bucket_name = bucket_name.to_s
            return nil unless (3..63) === bucket_name.size
            bucket_name.split('.').each do |component|
                return nil unless component[/^[a-z0-9]([a-z0-9-]*[a-z0-9])?$/]
            end
            true
        end

        def fetch_request_params(headers) #:nodoc:
            # default server to use
            server  = @params[:server]
            service = @params[:service].to_s
            service.chop! if service[%r{/$}] # remove trailing '/' from service
            # extract bucket name and check it's dns compartibility
            headers[:url].to_s[%r{^([a-z0-9._-]*)(/[^?]*)?(\?.+)?}i]
            bucket_name, key_path, params_list = $1, $2, $3
            # select request model
            if is_dns_bucket?(bucket_name)
                # fix a path
                server   = "#{bucket_name}.#{server}"
                key_path ||= '/'
                path     = "#{service}#{key_path}#{params_list}"
            else
                path = "#{service}/#{bucket_name}#{key_path}#{params_list}"
            end
            path_to_sign = "#{service}/#{bucket_name}#{key_path}#{params_list}"
#      path_to_sign = "/#{bucket_name}#{key_path}#{params_list}"
            [server, path, path_to_sign]
        end

        # Generates request hash for REST API.
        # Assumes that headers[:url] is URL encoded (use CGI::escape)
        def generate_rest_request(method, headers) # :nodoc:
            # calculate request data
            server, path, path_to_sign = fetch_request_params(headers)
            data = headers[:data]
            # remove unset(==optional) and symbolyc keys
            headers.each { |key, value| headers.delete(key) if (value.nil? || key.is_a?(Symbol)) }
            #
            headers['content-type'] ||= ''
            headers['date']         = Time.now.httpdate
            # create request
            request                 = "Net::HTTP::#{method.capitalize}".constantize.new(path)
            request.body = data if data
            # set request headers and meta headers
            headers.each { |key, value| request[key.to_s] = value }
            #generate auth strings
            auth_string              = canonical_string(request.method, path_to_sign, request.to_hash)
            signature                = AwsUtils::sign(@aws_secret_access_key, auth_string)
            # set other headers
            request['Authorization'] = "AWS #{@aws_access_key_id}:#{signature}"
            # prepare output hash
            {:request  => request,
             :server   => server,
             :port     => @params[:port],
             :protocol => @params[:protocol]}
        end

        # Sends request to Amazon and parses the response.
        # Raises AwsError if any banana happened.
        def request_info(request, parser, options={}, &block) # :nodoc:
            request_info2(request, parser, @params, :s3_connection, @logger, @@bench, options, &block)

        end


        # Returns an array of customer's buckets. Each item is a +hash+.
        #
        #  s3.list_all_my_buckets #=>
        #    [{:owner_id           => "00000000009314cc309ffe736daa2b264357476c7fea6efb2c3347ac3ab2792a",
        #      :owner_display_name => "root",
        #      :name               => "bucket_name",
        #      :creation_date      => "2007-04-19T18:47:43.000Z"}, ..., {...}]
        #
        def list_all_my_buckets(headers={})
            req_hash = generate_rest_request('GET', headers.merge(:url=>''))
            request_info(req_hash, S3ListAllMyBucketsParser.new(:logger => @logger))
        rescue
            on_exception
        end

        # Creates new bucket. Returns +true+ or an exception.
        #
        #  # create a bucket at American server
        #  s3.create_bucket('my-awesome-bucket-us') #=> true
        #  # create a bucket at European server
        #  s3.create_bucket('my-awesome-bucket-eu', :location => :eu) #=> true
        #
        def create_bucket(bucket, headers={})
            data = nil
            unless headers[:location].blank?
#                data = "<CreateBucketConfiguration><LocationConstraint>#{headers[:location].to_s.upcase}</LocationConstraint></CreateBucketConfiguration>"
                location = headers[:location].to_s
                location.upcase! if location == 'eu'
                data = "<CreateBucketConfiguration><LocationConstraint>#{location}</LocationConstraint></CreateBucketConfiguration>"
            end
            req_hash = generate_rest_request('PUT', headers.merge(:url=>bucket, :data => data))
            request_info(req_hash, RightHttp2xxParser.new)
        rescue Exception => e
            # if the bucket exists AWS returns an error for the location constraint interface. Drop it
            e.is_a?(Aws::AwsError) && e.message.include?('BucketAlreadyOwnedByYou') ? true : on_exception
        end

        # Retrieve bucket location
        #
        #  s3.create_bucket('my-awesome-bucket-us')        #=> true
        #  puts s3.bucket_location('my-awesome-bucket-us') #=> '' (Amazon's default value assumed)
        #
        #  s3.create_bucket('my-awesome-bucket-eu', :location => :eu) #=> true
        #  puts s3.bucket_location('my-awesome-bucket-eu')            #=> 'EU'
        #
        def bucket_location(bucket, headers={})
            req_hash = generate_rest_request('GET', headers.merge(:url=>"#{bucket}?location"))
            request_info(req_hash, S3BucketLocationParser.new)
        rescue
            on_exception
        end

        # Retrieves the logging configuration for a bucket.
        # Returns a hash of {:enabled, :targetbucket, :targetprefix}
        #
        # s3.interface.get_logging_parse(:bucket => "asset_bucket")
        #   => {:enabled=>true, :targetbucket=>"mylogbucket", :targetprefix=>"loggylogs/"}
        #
        #
        def get_logging_parse(params)
            AwsUtils.mandatory_arguments([:bucket], params)
            AwsUtils.allow_only([:bucket, :headers], params)
            params[:headers] = {} unless params[:headers]
            req_hash = generate_rest_request('GET', params[:headers].merge(:url=>"#{params[:bucket]}?logging"))
            request_info(req_hash, S3LoggingParser.new)
        rescue
            on_exception
        end

        # Sets logging configuration for a bucket from the XML configuration document.
        #   params:
        #    :bucket
        #    :xmldoc
        def put_logging(params)
            AwsUtils.mandatory_arguments([:bucket, :xmldoc], params)
            AwsUtils.allow_only([:bucket, :xmldoc, :headers], params)
            params[:headers] = {} unless params[:headers]
            req_hash = generate_rest_request('PUT', params[:headers].merge(:url=>"#{params[:bucket]}?logging", :data => params[:xmldoc]))
            request_info(req_hash, S3TrueParser.new)
        rescue
            on_exception
        end

        # Deletes new bucket. Bucket must be empty! Returns +true+ or an exception.
        #
        #  s3.delete_bucket('my_awesome_bucket')  #=> true
        #
        # See also: force_delete_bucket method
        #
        def delete_bucket(bucket, headers={})
            req_hash = generate_rest_request('DELETE', headers.merge(:url=>bucket))
            request_info(req_hash, RightHttp2xxParser.new)
        rescue
            on_exception
        end

        # Returns an array of bucket's keys. Each array item (key data) is a +hash+.
        #
        #  s3.list_bucket('my_awesome_bucket', { 'prefix'=>'t', 'marker'=>'', 'max-keys'=>5, delimiter=>'' }) #=>
        #    [{:key                => "test1",
        #      :last_modified      => "2007-05-18T07:00:59.000Z",
        #      :owner_id           => "00000000009314cc309ffe736daa2b264357476c7fea6efb2c3347ac3ab2792a",
        #      :owner_display_name => "root",
        #      :e_tag              => "000000000059075b964b07152d234b70",
        #      :storage_class      => "STANDARD",
        #      :size               => 3,
        #      :service=> {'is_truncated' => false,
        #                  'prefix'       => "t",
        #                  'marker'       => "",
        #                  'name'         => "my_awesome_bucket",
        #                  'max-keys'     => "5"}, ..., {...}]
        #
        def list_bucket(bucket, options={}, headers={})
            bucket += '?'+options.map { |k, v| "#{k.to_s}=#{CGI::escape v.to_s}" }.join('&') unless options.blank?
            req_hash = generate_rest_request('GET', headers.merge(:url=>bucket))
            request_info(req_hash, S3ListBucketParser.new(:logger => @logger))
        rescue
            on_exception
        end

        # Incrementally list the contents of a bucket. Yields the following hash to a block:
        #  s3.incrementally_list_bucket('my_awesome_bucket', { 'prefix'=>'t', 'marker'=>'', 'max-keys'=>5, delimiter=>'' }) yields
        #   {
        #     :name => 'bucketname',
        #     :prefix => 'subfolder/',
        #     :marker => 'fileN.jpg',
        #     :max_keys => 234,
        #     :delimiter => '/',
        #     :is_truncated => true,
        #     :next_marker => 'fileX.jpg',
        #     :contents => [
        #       { :key => "file1",
        #         :last_modified => "2007-05-18T07:00:59.000Z",
        #         :e_tag => "000000000059075b964b07152d234b70",
        #         :size => 3,
        #         :storage_class => "STANDARD",
        #         :owner_id => "00000000009314cc309ffe736daa2b264357476c7fea6efb2c3347ac3ab2792a",
        #         :owner_display_name => "root"
        #       }, { :key, ...}, ... {:key, ...}
        #     ]
        #     :common_prefixes => [
        #       "prefix1",
        #       "prefix2",
        #       ...,
        #       "prefixN"
        #     ]
        #   }
        def incrementally_list_bucket(bucket, options={}, headers={}, &block)
            internal_options = options.symbolize_keys
            begin
                internal_bucket = bucket.dup
                internal_bucket += '?'+internal_options.map { |k, v| "#{k.to_s}=#{CGI::escape v.to_s}" }.join('&') unless internal_options.blank?
                req_hash            = generate_rest_request('GET', headers.merge(:url=>internal_bucket))
                response            = request_info(req_hash, S3ImprovedListBucketParser.new(:logger => @logger))
                there_are_more_keys = response[:is_truncated]
                if (there_are_more_keys)
                    internal_options[:marker] = decide_marker(response)
                    total_results             = response[:contents].length + response[:common_prefixes].length
                    internal_options[:'max-keys'] ? (internal_options[:'max-keys'] -= total_results) : nil
                end
                yield response
            end while there_are_more_keys && under_max_keys(internal_options)
            true
        rescue
            on_exception
        end


        private
        def decide_marker(response)
            return response[:next_marker].dup if response[:next_marker]
            last_key    = response[:contents].last[:key]
            last_prefix = response[:common_prefixes].last
            if (!last_key)
                return nil if (!last_prefix)
                last_prefix.dup
            elsif (!last_prefix)
                last_key.dup
            else
                last_key > last_prefix ? last_key.dup : last_prefix.dup
            end
        end

        def under_max_keys(internal_options)
            internal_options[:'max-keys'] ? internal_options[:'max-keys'] > 0 : true
        end

        public
        # Saves object to Amazon. Returns +true+  or an exception.
        # Any header starting with AMAZON_METADATA_PREFIX is considered
        # user metadata. It will be stored with the object and returned
        # when you retrieve the object. The total size of the HTTP
        # request, not including the body, must be less than 4 KB.
        #
        #  s3.put('my_awesome_bucket', 'log/current/1.log', 'Ola-la!', 'x-amz-meta-family'=>'Woho556!') #=> true
        #
        # This method is capable of 'streaming' uploads; that is, it can upload
        # data from a file or other IO object without first reading all the data
        # into memory.  This is most useful for large PUTs - it is difficult to read
        # a 2 GB file entirely into memory before sending it to S3.
        # To stream an upload, pass an object that responds to 'read' (like the read
        # method of IO) and to either 'lstat' or 'size'.  For files, this means
        # streaming is enabled by simply making the call:
        #
        #  s3.put(bucket_name, 'S3keyname.forthisfile',  File.open('localfilename.dat'))
        #
        # If the IO object you wish to stream from responds to the read method but
        # doesn't implement lstat or size, you can extend the object dynamically
        # to implement these methods, or define your own class which defines these
        # methods.  Be sure that your class returns 'nil' from read() after having
        # read 'size' bytes. Otherwise S3 will drop the socket after
        # 'Content-Length' bytes have been uploaded, and HttpConnection will
        # interpret this as an error.
        #
        # This method now supports very large PUTs, where very large
        # is > 2 GB.
        #
        # For Win32 users: Files and IO objects should be opened in binary mode.  If
        # a text mode IO object is passed to PUT, it will be converted to binary
        # mode.
        #

        def put(bucket, key, data=nil, headers={})
            # On Windows, if someone opens a file in text mode, we must reset it so
            # to binary mode for streaming to work properly
            if (data.respond_to?(:binmode))
                data.binmode
            end
            data_size = data.respond_to?(:lstat) ? data.lstat.size :
                    (data.respond_to?(:size) ? data.size : 0)
            if (data_size >= USE_100_CONTINUE_PUT_SIZE)
                headers['expect'] = '100-continue'
            end
            req_hash = generate_rest_request('PUT', headers.merge(:url             =>"#{bucket}/#{CGI::escape key}", :data=>data,
                                                                  'Content-Length' => data_size.to_s))
            request_info(req_hash, RightHttp2xxParser.new)
        rescue
            on_exception
        end


        # New experimental API for uploading objects, introduced in Aws 1.8.1.
        # store_object is similar in function to the older function put, but returns the full response metadata.  It also allows for optional verification
        # of object md5 checksums on upload.  Parameters are passed as hash entries and are checked for completeness as well as for spurious arguments.
        # The hash of the response headers contains useful information like the Amazon request ID and the object ETag (MD5 checksum).
        #
        # If the optional :md5 argument is provided, store_object verifies that the given md5 matches the md5 returned by S3.  The :verified_md5 field in the response hash is
        # set true or false depending on the outcome of this check.  If no :md5 argument is given, :verified_md5 will be false in the response.
        #
        # The optional argument of :headers allows the caller to specify arbitrary request header values.
        #
        # s3.store_object(:bucket => "foobucket", :key => "foo", :md5 => "a507841b1bc8115094b00bbe8c1b2954", :data => "polemonium" )
        #   => {"x-amz-id-2"=>"SVsnS2nfDaR+ixyJUlRKM8GndRyEMS16+oZRieamuL61pPxPaTuWrWtlYaEhYrI/",
        #       "etag"=>"\"a507841b1bc8115094b00bbe8c1b2954\"",
        #       "date"=>"Mon, 29 Sep 2008 18:57:46 GMT",
        #       :verified_md5=>true,
        #       "x-amz-request-id"=>"63916465939995BA",
        #       "server"=>"AmazonS3",
        #       "content-length"=>"0"}
        #
        # s3.store_object(:bucket => "foobucket", :key => "foo", :data => "polemonium" )
        #   => {"x-amz-id-2"=>"MAt9PLjgLX9UYJ5tV2fI/5dBZdpFjlzRVpWgBDpvZpl+V+gJFcBMW2L+LBstYpbR",
        #       "etag"=>"\"a507841b1bc8115094b00bbe8c1b2954\"",
        #       "date"=>"Mon, 29 Sep 2008 18:58:56 GMT",
        #       :verified_md5=>false,
        #       "x-amz-request-id"=>"3B25A996BC2CDD3B",
        #       "server"=>"AmazonS3",
        #       "content-length"=>"0"}

        def store_object(params)
            AwsUtils.allow_only([:bucket, :key, :data, :headers, :md5], params)
            AwsUtils.mandatory_arguments([:bucket, :key, :data], params)
            params[:headers] = {} unless params[:headers]

            params[:data].binmode if (params[:data].respond_to?(:binmode)) # On Windows, if someone opens a file in text mode, we must reset it to binary mode for streaming to work properly
            if (params[:data].respond_to?(:lstat) && params[:data].lstat.size >= USE_100_CONTINUE_PUT_SIZE) ||
                    (params[:data].respond_to?(:size) && params[:data].size >= USE_100_CONTINUE_PUT_SIZE)
                params[:headers]['expect'] = '100-continue'
            end

            req_hash = generate_rest_request('PUT', params[:headers].merge(:url=>"#{params[:bucket]}/#{CGI::escape params[:key]}", :data=>params[:data]))
            resp     = request_info(req_hash, S3HttpResponseHeadParser.new)
            if (params[:md5])
                resp[:verified_md5] = (resp['etag'].gsub(/\"/, '') == params[:md5]) ? true : false
            else
                resp[:verified_md5] = false
            end
            resp
        rescue
            on_exception
        end

        # Identical in function to store_object, but requires verification that the returned ETag is identical to the checksum passed in by the user as the 'md5' argument.
        # If the check passes, returns the response metadata with the "verified_md5" field set true.  Raises an exception if the checksums conflict.
        # This call is implemented as a wrapper around store_object and the user may gain different semantics by creating a custom wrapper.
        #
        # s3.store_object_and_verify(:bucket => "foobucket", :key => "foo", :md5 => "a507841b1bc8115094b00bbe8c1b2954", :data => "polemonium" )
        #   => {"x-amz-id-2"=>"IZN3XsH4FlBU0+XYkFTfHwaiF1tNzrm6dIW2EM/cthKvl71nldfVC0oVQyydzWpb",
        #       "etag"=>"\"a507841b1bc8115094b00bbe8c1b2954\"",
        #       "date"=>"Mon, 29 Sep 2008 18:38:32 GMT",
        #       :verified_md5=>true,
        #       "x-amz-request-id"=>"E8D7EA4FE00F5DF7",
        #       "server"=>"AmazonS3",
        #       "content-length"=>"0"}
        #
        # s3.store_object_and_verify(:bucket => "foobucket", :key => "foo", :md5 => "a507841b1bc8115094b00bbe8c1b2953", :data => "polemonium" )
        #   Aws::AwsError: Uploaded object failed MD5 checksum verification: {"x-amz-id-2"=>"HTxVtd2bf7UHHDn+WzEH43MkEjFZ26xuYvUzbstkV6nrWvECRWQWFSx91z/bl03n",
        #                                                                          "etag"=>"\"a507841b1bc8115094b00bbe8c1b2954\"",
        #                                                                          "date"=>"Mon, 29 Sep 2008 18:38:41 GMT",
        #                                                                          :verified_md5=>false,
        #                                                                          "x-amz-request-id"=>"0D7ADE09F42606F2",
        #                                                                          "server"=>"AmazonS3",
        #                                                                          "content-length"=>"0"}
        def store_object_and_verify(params)
            AwsUtils.mandatory_arguments([:md5], params)
            r = store_object(params)
            r[:verified_md5] ? (return r) : (raise AwsError.new("Uploaded object failed MD5 checksum verification: #{r.inspect}"))
        end

        # Retrieves object data from Amazon. Returns a +hash+  or an exception.
        #
        #  s3.get('my_awesome_bucket', 'log/curent/1.log') #=>
        #
        #      {:object  => "Ola-la!",
        #       :headers => {"last-modified"     => "Wed, 23 May 2007 09:08:04 GMT",
        #                    "content-type"      => "",
        #                    "etag"              => "\"000000000096f4ee74bc4596443ef2a4\"",
        #                    "date"              => "Wed, 23 May 2007 09:08:03 GMT",
        #                    "x-amz-id-2"        => "ZZZZZZZZZZZZZZZZZZZZ1HJXZoehfrS4QxcxTdNGldR7w/FVqblP50fU8cuIMLiu",
        #                    "x-amz-meta-family" => "Woho556!",
        #                    "x-amz-request-id"  => "0000000C246D770C",
        #                    "server"            => "AmazonS3",
        #                    "content-length"    => "7"}}
        #
        # If a block is provided, yields incrementally to the block as
        # the response is read.  For large responses, this function is ideal as
        # the response can be 'streamed'.  The hash containing header fields is
        # still returned.
        # Example:
        # foo = File.new('./chunder.txt', File::CREAT|File::RDWR)
        # rhdr = s3.get('aws-test', 'Cent5V1_7_1.img.part.00') do |chunk|
        #   foo.write(chunk)
        # end
        # foo.close
        #

        def get(bucket, key, headers={}, &block)
            req_hash = generate_rest_request('GET', headers.merge(:url=>"#{bucket}/#{CGI::escape key}"))
            request_info(req_hash, S3HttpResponseBodyParser.new, &block)
        rescue
            on_exception
        end

        # New experimental API for retrieving objects, introduced in Aws 1.8.1.
        # retrieve_object is similar in function to the older function get.  It allows for optional verification
        # of object md5 checksums on retrieval.  Parameters are passed as hash entries and are checked for completeness as well as for spurious arguments.
        #
        # If the optional :md5 argument is provided, retrieve_object verifies that the given md5 matches the md5 returned by S3.  The :verified_md5 field in the response hash is
        # set true or false depending on the outcome of this check.  If no :md5 argument is given, :verified_md5 will be false in the response.
        #
        # The optional argument of :headers allows the caller to specify arbitrary request header values.
        # Mandatory arguments:
        #   :bucket - the bucket in which the object is stored
        #   :key    - the object address (or path) within the bucket
        # Optional arguments:
        #   :headers - hash of additional HTTP headers to include with the request
        #   :md5     - MD5 checksum against which to verify the retrieved object
        #
        #  s3.retrieve_object(:bucket => "foobucket", :key => "foo")
        #    => {:verified_md5=>false,
        #        :headers=>{"last-modified"=>"Mon, 29 Sep 2008 18:58:56 GMT",
        #                   "x-amz-id-2"=>"2Aj3TDz6HP5109qly//18uHZ2a1TNHGLns9hyAtq2ved7wmzEXDOPGRHOYEa3Qnp",
        #                   "content-type"=>"",
        #                   "etag"=>"\"a507841b1bc8115094b00bbe8c1b2954\"",
        #                   "date"=>"Tue, 30 Sep 2008 00:52:44 GMT",
        #                   "x-amz-request-id"=>"EE4855DE27A2688C",
        #                   "server"=>"AmazonS3",
        #                   "content-length"=>"10"},
        #        :object=>"polemonium"}
        #
        #  s3.retrieve_object(:bucket => "foobucket", :key => "foo", :md5=>'a507841b1bc8115094b00bbe8c1b2954')
        #    => {:verified_md5=>true,
        #        :headers=>{"last-modified"=>"Mon, 29 Sep 2008 18:58:56 GMT",
        #                   "x-amz-id-2"=>"mLWQcI+VuKVIdpTaPXEo84g0cz+vzmRLbj79TS8eFPfw19cGFOPxuLy4uGYVCvdH",
        #                   "content-type"=>"", "etag"=>"\"a507841b1bc8115094b00bbe8c1b2954\"",
        #                   "date"=>"Tue, 30 Sep 2008 00:53:08 GMT",
        #                   "x-amz-request-id"=>"6E7F317356580599",
        #                   "server"=>"AmazonS3",
        #                   "content-length"=>"10"},
        #        :object=>"polemonium"}
        # If a block is provided, yields incrementally to the block as
        # the response is read.  For large responses, this function is ideal as
        # the response can be 'streamed'.  The hash containing header fields is
        # still returned.
        def retrieve_object(params, &block)
            AwsUtils.mandatory_arguments([:bucket, :key], params)
            AwsUtils.allow_only([:bucket, :key, :headers, :md5], params)
            params[:headers] = {} unless params[:headers]
            req_hash            = generate_rest_request('GET', params[:headers].merge(:url=>"#{params[:bucket]}/#{CGI::escape params[:key]}"))
            resp                = request_info(req_hash, S3HttpResponseBodyParser.new, &block)
            resp[:verified_md5] = false
            if (params[:md5] && (resp[:headers]['etag'].gsub(/\"/, '') == params[:md5]))
                resp[:verified_md5] = true
            end
            resp
        rescue
            on_exception
        end

        # Identical in function to retrieve_object, but requires verification that the returned ETag is identical to the checksum passed in by the user as the 'md5' argument.
        # If the check passes, returns the response metadata with the "verified_md5" field set true.  Raises an exception if the checksums conflict.
        # This call is implemented as a wrapper around retrieve_object and the user may gain different semantics by creating a custom wrapper.
        def retrieve_object_and_verify(params, &block)
            AwsUtils.mandatory_arguments([:md5], params)
            resp = retrieve_object(params, &block)
            return resp if resp[:verified_md5]
            raise AwsError.new("Retrieved object failed MD5 checksum verification: #{resp.inspect}")
        end

        # Retrieves object metadata. Returns a +hash+ of http_response_headers.
        #
        #  s3.head('my_awesome_bucket', 'log/curent/1.log') #=>
        #    {"last-modified"     => "Wed, 23 May 2007 09:08:04 GMT",
        #     "content-type"      => "",
        #     "etag"              => "\"000000000096f4ee74bc4596443ef2a4\"",
        #     "date"              => "Wed, 23 May 2007 09:08:03 GMT",
        #     "x-amz-id-2"        => "ZZZZZZZZZZZZZZZZZZZZ1HJXZoehfrS4QxcxTdNGldR7w/FVqblP50fU8cuIMLiu",
        #     "x-amz-meta-family" => "Woho556!",
        #     "x-amz-request-id"  => "0000000C246D770C",
        #     "server"            => "AmazonS3",
        #     "content-length"    => "7"}
        #
        def head(bucket, key, headers={})
            req_hash = generate_rest_request('HEAD', headers.merge(:url=>"#{bucket}/#{CGI::escape key}"))
            request_info(req_hash, S3HttpResponseHeadParser.new)
        rescue
            on_exception
        end

        # Deletes key. Returns +true+ or an exception.
        #
        #  s3.delete('my_awesome_bucket', 'log/curent/1.log') #=> true
        #
        def delete(bucket, key='', headers={})
            req_hash = generate_rest_request('DELETE', headers.merge(:url=>"#{bucket}/#{CGI::escape key}"))
            request_info(req_hash, RightHttp2xxParser.new)
        rescue
            on_exception
        end

        # Copy an object.
        #  directive: :copy    - copy meta-headers from source (default value)
        #             :replace - replace meta-headers by passed ones
        #
        #  # copy a key with meta-headers
        #  s3.copy('b1', 'key1', 'b1', 'key1_copy') #=> {:e_tag=>"\"e8b...8d\"", :last_modified=>"2008-05-11T10:25:22.000Z"}
        #
        #  # copy a key, overwrite meta-headers
        #  s3.copy('b1', 'key2', 'b1', 'key2_copy', :replace, 'x-amz-meta-family'=>'Woho555!') #=> {:e_tag=>"\"e8b...8d\"", :last_modified=>"2008-05-11T10:26:22.000Z"}
        #
        # see: http://docs.amazonwebservices.com/AmazonS3/2006-03-01/UsingCopyingObjects.html
        #      http://docs.amazonwebservices.com/AmazonS3/2006-03-01/RESTObjectCOPY.html
        #
        def copy(src_bucket, src_key, dest_bucket, dest_key=nil, directive=:copy, headers={})
            dest_key                            ||= src_key
            headers['x-amz-metadata-directive'] = directive.to_s.upcase
            headers['x-amz-copy-source']        = "#{src_bucket}/#{CGI::escape src_key}"
            req_hash                            = generate_rest_request('PUT', headers.merge(:url=>"#{dest_bucket}/#{CGI::escape dest_key}"))
            request_info(req_hash, S3CopyParser.new)
        rescue
            on_exception
        end

        # Move an object.
        #  directive: :copy    - copy meta-headers from source (default value)
        #             :replace - replace meta-headers by passed ones
        #
        #  # move bucket1/key1 to bucket1/key2
        #  s3.move('bucket1', 'key1', 'bucket1', 'key2') #=> {:e_tag=>"\"e8b...8d\"", :last_modified=>"2008-05-11T10:27:22.000Z"}
        #
        #  # move bucket1/key1 to bucket2/key2 with new meta-headers assignment
        #  s3.copy('bucket1', 'key1', 'bucket2', 'key2', :replace, 'x-amz-meta-family'=>'Woho555!') #=> {:e_tag=>"\"e8b...8d\"", :last_modified=>"2008-05-11T10:28:22.000Z"}
        #
        def move(src_bucket, src_key, dest_bucket, dest_key=nil, directive=:copy, headers={})
            copy_result = copy(src_bucket, src_key, dest_bucket, dest_key, directive, headers)
            # delete an original key if it differs from a destination one
            delete(src_bucket, src_key) unless src_bucket == dest_bucket && src_key == dest_key
            copy_result
        end

        # Rename an object.
        #
        #  # rename bucket1/key1 to bucket1/key2
        #  s3.rename('bucket1', 'key1', 'key2') #=> {:e_tag=>"\"e8b...8d\"", :last_modified=>"2008-05-11T10:29:22.000Z"}
        #
        def rename(src_bucket, src_key, dest_key, headers={})
            move(src_bucket, src_key, src_bucket, dest_key, :copy, headers)
        end

        # Retieves the ACL (access control policy) for a bucket or object. Returns a hash of headers and xml doc with ACL data. See: http://docs.amazonwebservices.com/AmazonS3/2006-03-01/RESTAccessPolicy.html.
        #
        #  s3.get_acl('my_awesome_bucket', 'log/curent/1.log') #=>
        #    {:headers => {"x-amz-id-2"=>"B3BdDMDUz+phFF2mGBH04E46ZD4Qb9HF5PoPHqDRWBv+NVGeA3TOQ3BkVvPBjgxX",
        #                  "content-type"=>"application/xml;charset=ISO-8859-1",
        #                  "date"=>"Wed, 23 May 2007 09:40:16 GMT",
        #                  "x-amz-request-id"=>"B183FA7AB5FBB4DD",
        #                  "server"=>"AmazonS3",
        #                  "transfer-encoding"=>"chunked"},
        #     :object  => "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<AccessControlPolicy xmlns=\"http://s3.amazonaws.com/doc/2006-03-01/\"><Owner>
        #                  <ID>16144ab2929314cc309ffe736daa2b264357476c7fea6efb2c3347ac3ab2792a</ID><DisplayName>root</DisplayName></Owner>
        #                  <AccessControlList><Grant><Grantee xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:type=\"CanonicalUser\"><ID>
        #                  16144ab2929314cc309ffe736daa2b264357476c7fea6efb2c3347ac3ab2792a</ID><DisplayName>root</DisplayName></Grantee>
        #                  <Permission>FULL_CONTROL</Permission></Grant></AccessControlList></AccessControlPolicy>" }
        #
        def get_acl(bucket, key='', headers={})
            key      = key.blank? ? '' : "/#{CGI::escape key}"
            req_hash = generate_rest_request('GET', headers.merge(:url=>"#{bucket}#{key}?acl"))
            request_info(req_hash, S3HttpResponseBodyParser.new)
        rescue
            on_exception
        end

        # Retieves the ACL (access control policy) for a bucket or object.
        # Returns a hash of {:owner, :grantees}
        #
        #  s3.get_acl_parse('my_awesome_bucket', 'log/curent/1.log') #=>
        #
        #  { :grantees=>
        #    { "16...2a"=>
        #      { :display_name=>"root",
        #        :permissions=>["FULL_CONTROL"],
        #        :attributes=>
        #         { "xsi:type"=>"CanonicalUser",
        #           "xmlns:xsi"=>"http://www.w3.org/2001/XMLSchema-instance"}},
        #     "http://acs.amazonaws.com/groups/global/AllUsers"=>
        #       { :display_name=>"AllUsers",
        #         :permissions=>["READ"],
        #         :attributes=>
        #          { "xsi:type"=>"Group",
        #            "xmlns:xsi"=>"http://www.w3.org/2001/XMLSchema-instance"}}},
        #   :owner=>
        #     { :id=>"16..2a",
        #       :display_name=>"root"}}
        #
        def get_acl_parse(bucket, key='', headers={})
            key               = key.blank? ? '' : "/#{CGI::escape key}"
            req_hash          = generate_rest_request('GET', headers.merge(:url=>"#{bucket}#{key}?acl"))
            acl               = request_info(req_hash, S3AclParser.new(:logger => @logger))
            result            = {}
            result[:owner]    = acl[:owner]
            result[:grantees] = {}
            acl[:grantees].each do |grantee|
                key = grantee[:id] || grantee[:uri]
                if result[:grantees].key?(key)
                    result[:grantees][key][:permissions] << grantee[:permissions]
                else
                    result[:grantees][key] =
                            {:display_name => grantee[:display_name] || grantee[:uri].to_s[/[^\/]*$/],
                             :permissions  => grantee[:permissions].lines.to_a,
                             :attributes   => grantee[:attributes]}
                end
            end
            result
        rescue
            on_exception
        end

        # Sets the ACL on a bucket or object.
        def put_acl(bucket, key, acl_xml_doc, headers={})
            key      = key.blank? ? '' : "/#{CGI::escape key}"
            req_hash = generate_rest_request('PUT', headers.merge(:url=>"#{bucket}#{key}?acl", :data=>acl_xml_doc))
            request_info(req_hash, S3HttpResponseBodyParser.new)
        rescue
            on_exception
        end

        # Retieves the ACL (access control policy) for a bucket. Returns a hash of headers and xml doc with ACL data.
        def get_bucket_acl(bucket, headers={})
            return get_acl(bucket, '', headers)
        rescue
            on_exception
        end

        # Sets the ACL on a bucket only.
        def put_bucket_acl(bucket, acl_xml_doc, headers={})
            return put_acl(bucket, '', acl_xml_doc, headers)
        rescue
            on_exception
        end

        def get_bucket_policy(bucket)
            req_hash = generate_rest_request('GET', {:url=>"#{bucket}?policy"})
            request_info(req_hash, S3HttpResponseBodyParser.new)
        rescue
            on_exception
        end

        def put_bucket_policy(bucket, policy)
            key      = key.blank? ? '' : "/#{CGI::escape key}"
            req_hash = generate_rest_request('PUT', {:url=>"#{bucket}?policy", :data=>policy})
            request_info(req_hash, S3HttpResponseBodyParser.new)
        rescue
            on_exception
        end

        # Removes all keys from bucket. Returns +true+ or an exception.
        #
        #  s3.clear_bucket('my_awesome_bucket') #=> true
        #
        def clear_bucket(bucket)
            incrementally_list_bucket(bucket) do |results|
                results[:contents].each { |key| delete(bucket, key[:key]) }
            end
            true
        rescue
            on_exception
        end

        # Deletes all keys in bucket then deletes bucket. Returns +true+ or an exception.
        #
        #  s3.force_delete_bucket('my_awesome_bucket')
        #
        def force_delete_bucket(bucket)
            clear_bucket(bucket)
            delete_bucket(bucket)
        rescue
            on_exception
        end

        # Deletes all keys where the 'folder_key' may be assumed as 'folder' name. Returns an array of string keys that have been deleted.
        #
        #  s3.list_bucket('my_awesome_bucket').map{|key_data| key_data[:key]} #=> ['test','test/2/34','test/3','test1','test1/logs']
        #  s3.delete_folder('my_awesome_bucket','test')                       #=> ['test','test/2/34','test/3']
        #
        def delete_folder(bucket, folder_key, separator='/')
            folder_key.chomp!(separator)
            allkeys = []
            incrementally_list_bucket(bucket, {'prefix' => folder_key}) do |results|
                keys = results[:contents].map { |s3_key| s3_key[:key][/^#{folder_key}($|#{separator}.*)/] ? s3_key[:key] : nil }.compact
                keys.each { |key| delete(bucket, key) }
                allkeys << keys
            end
            allkeys
        rescue
            on_exception
        end

        # Retrieves object data only (headers are omitted). Returns +string+ or an exception.
        #
        #  s3.get('my_awesome_bucket', 'log/curent/1.log') #=> 'Ola-la!'
        #
        def get_object(bucket, key, headers={})
            get(bucket, key, headers)[:object]
        rescue
            on_exception
        end

        #-----------------------------------------------------------------
        #      Query API: Links
        #-----------------------------------------------------------------

        # Generates link for QUERY API
        def generate_link(method, headers={}, expires=nil) #:nodoc:
            # calculate request data
            server, path, path_to_sign = fetch_request_params(headers)
            # expiration time
            expires ||= DEFAULT_EXPIRES_AFTER
            expires = Time.now.utc + expires if expires.is_a?(Fixnum) && (expires < ONE_YEAR_IN_SECONDS)
            expires = expires.to_i
            # remove unset(==optional) and symbolyc keys
            headers.each { |key, value| headers.delete(key) if (value.nil? || key.is_a?(Symbol)) }
            #generate auth strings
            auth_string = canonical_string(method, path_to_sign, headers, expires)
            signature   = CGI::escape(Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest::Digest.new("sha1"), @aws_secret_access_key, auth_string)).strip)
            # path building
            addon       = "Signature=#{signature}&Expires=#{expires}&AWSAccessKeyId=#{@aws_access_key_id}"
            path        += path[/\?/] ? "&#{addon}" : "?#{addon}"
            "#{@params[:protocol]}://#{server}:#{@params[:port]}#{path}"
        rescue
            on_exception
        end

        # Generates link for 'ListAllMyBuckets'.
        #
        #  s3.list_all_my_buckets_link #=> url string
        #
        def list_all_my_buckets_link(expires=nil, headers={})
            generate_link('GET', headers.merge(:url=>''), expires)
        rescue
            on_exception
        end

        # Generates link for 'CreateBucket'.
        #
        #  s3.create_bucket_link('my_awesome_bucket') #=> url string
        #
        def create_bucket_link(bucket, expires=nil, headers={})
            generate_link('PUT', headers.merge(:url=>bucket), expires)
        rescue
            on_exception
        end

        # Generates link for 'DeleteBucket'.
        #
        #  s3.delete_bucket_link('my_awesome_bucket') #=> url string
        #
        def delete_bucket_link(bucket, expires=nil, headers={})
            generate_link('DELETE', headers.merge(:url=>bucket), expires)
        rescue
            on_exception
        end

        # Generates link for 'ListBucket'.
        #
        #  s3.list_bucket_link('my_awesome_bucket') #=> url string
        #
        def list_bucket_link(bucket, options=nil, expires=nil, headers={})
            bucket += '?' + options.map { |k, v| "#{k.to_s}=#{CGI::escape v.to_s}" }.join('&') unless options.blank?
            generate_link('GET', headers.merge(:url=>bucket), expires)
        rescue
            on_exception
        end

        # Generates link for 'PutObject'.
        #
        #  s3.put_link('my_awesome_bucket',key, object) #=> url string
        #
        def put_link(bucket, key, data=nil, expires=nil, headers={})
            generate_link('PUT', headers.merge(:url=>"#{bucket}/#{AwsUtils::URLencode key}", :data=>data), expires)
        rescue
            on_exception
        end

        # Generates link for 'GetObject'.
        #
        # if a bucket comply with virtual hosting naming then retuns a link with the
        # bucket as a part of host name:
        #
        #  s3.get_link('my-awesome-bucket',key) #=> https://my-awesome-bucket.s3.amazonaws.com:443/asia%2Fcustomers?Signature=nh7...
        #
        # otherwise returns an old style link (the bucket is a part of path):
        #
        #  s3.get_link('my_awesome_bucket',key) #=> https://s3.amazonaws.com:443/my_awesome_bucket/asia%2Fcustomers?Signature=QAO...
        #
        # see http://docs.amazonwebservices.com/AmazonS3/2006-03-01/VirtualHosting.html
        def get_link(bucket, key, expires=nil, headers={})
            generate_link('GET', headers.merge(:url=>"#{bucket}/#{AwsUtils::URLencode key}"), expires)
        rescue
            on_exception
        end

        # Generates link for 'HeadObject'.
        #
        #  s3.head_link('my_awesome_bucket',key) #=> url string
        #
        def head_link(bucket, key, expires=nil, headers={})
            generate_link('HEAD', headers.merge(:url=>"#{bucket}/#{AwsUtils::URLencode key}"), expires)
        rescue
            on_exception
        end

        # Generates link for 'DeleteObject'.
        #
        #  s3.delete_link('my_awesome_bucket',key) #=> url string
        #
        def delete_link(bucket, key, expires=nil, headers={})
            generate_link('DELETE', headers.merge(:url=>"#{bucket}/#{AwsUtils::URLencode key}"), expires)
        rescue
            on_exception
        end


        # Generates link for 'GetACL'.
        #
        #  s3.get_acl_link('my_awesome_bucket',key) #=> url string
        #
        def get_acl_link(bucket, key='', headers={})
            return generate_link('GET', headers.merge(:url=>"#{bucket}/#{AwsUtils::URLencode key}?acl"))
        rescue
            on_exception
        end

        # Generates link for 'PutACL'.
        #
        #  s3.put_acl_link('my_awesome_bucket',key) #=> url string
        #
        def put_acl_link(bucket, key='', headers={})
            return generate_link('PUT', headers.merge(:url=>"#{bucket}/#{AwsUtils::URLencode key}?acl"))
        rescue
            on_exception
        end

        # Generates link for 'GetBucketACL'.
        #
        #  s3.get_acl_link('my_awesome_bucket',key) #=> url string
        #
        def get_bucket_acl_link(bucket, headers={})
            return get_acl_link(bucket, '', headers)
        rescue
            on_exception
        end

        # Generates link for 'PutBucketACL'.
        #
        #  s3.put_acl_link('my_awesome_bucket',key) #=> url string
        #
        def put_bucket_acl_link(bucket, acl_xml_doc, headers={})
            return put_acl_link(bucket, '', acl_xml_doc, headers)
        rescue
            on_exception
        end

        #-----------------------------------------------------------------
        #      PARSERS:
        #-----------------------------------------------------------------

        class S3ListAllMyBucketsParser < AwsParser # :nodoc:
            def reset
                @result = []
                @owner  = {}
            end

            def tagstart(name, attributes)
                @current_bucket = {} if name == 'Bucket'
            end

            def tagend(name)
                case name
                    when 'ID';
                        @owner[:owner_id] = @text
                    when 'DisplayName';
                        @owner[:owner_display_name] = @text
                    when 'Name';
                        @current_bucket[:name] = @text
                    when 'CreationDate';
                        @current_bucket[:creation_date] = @text
                    when 'Bucket';
                        @result << @current_bucket.merge(@owner)
                end
            end
        end

        class S3ListBucketParser < AwsParser # :nodoc:
            def reset
                @result      = []
                @service     = {}
                @current_key = {}
            end

            def tagstart(name, attributes)
                @current_key = {} if name == 'Contents'
            end

            def tagend(name)
                case name
                    # service info
                    when 'Name';
                        @service['name'] = @text
                    when 'Prefix';
                        @service['prefix'] = @text
                    when 'Marker';
                        @service['marker'] = @text
                    when 'MaxKeys';
                        @service['max-keys'] = @text
                    when 'Delimiter';
                        @service['delimiter'] = @text
                    when 'IsTruncated';
                        @service['is_truncated'] = (@text =~ /false/ ? false : true)
                    # key data
                    when 'Key';
                        @current_key[:key] = @text
                    when 'LastModified';
                        @current_key[:last_modified] = @text
                    when 'ETag';
                        @current_key[:e_tag] = @text
                    when 'Size';
                        @current_key[:size] = @text.to_i
                    when 'StorageClass';
                        @current_key[:storage_class] = @text
                    when 'ID';
                        @current_key[:owner_id] = @text
                    when 'DisplayName';
                        @current_key[:owner_display_name] = @text
                    when 'Contents';
                        @current_key[:service] = @service; @result << @current_key
                end
            end
        end

        class S3ImprovedListBucketParser < AwsParser # :nodoc:
            def reset
                @result                   = {}
                @result[:contents]        = []
                @result[:common_prefixes] = []
                @contents                 = []
                @current_key              = {}
                @common_prefixes          = []
                @in_common_prefixes       = false
            end

            def tagstart(name, attributes)
                @current_key = {} if name == 'Contents'
                @in_common_prefixes = true if name == 'CommonPrefixes'
            end

            def tagend(name)
                case name
                    # service info
                    when 'Name';
                        @result[:name] = @text
                    # Amazon uses the same tag for the search prefix and for the entries
                    # in common prefix...so use our simple flag to see which element
                    # we are parsing
                    when 'Prefix';
                        @in_common_prefixes ? @common_prefixes << @text : @result[:prefix] = @text
                    when 'Marker';
                        @result[:marker] = @text
                    when 'MaxKeys';
                        @result[:max_keys] = @text
                    when 'Delimiter';
                        @result[:delimiter] = @text
                    when 'IsTruncated';
                        @result[:is_truncated] = (@text =~ /false/ ? false : true)
                    when 'NextMarker';
                        @result[:next_marker] = @text
                    # key data
                    when 'Key';
                        @current_key[:key] = @text
                    when 'LastModified';
                        @current_key[:last_modified] = @text
                    when 'ETag';
                        @current_key[:e_tag] = @text
                    when 'Size';
                        @current_key[:size] = @text.to_i
                    when 'StorageClass';
                        @current_key[:storage_class] = @text
                    when 'ID';
                        @current_key[:owner_id] = @text
                    when 'DisplayName';
                        @current_key[:owner_display_name] = @text
                    when 'Contents';
                        @result[:contents] << @current_key
                    # Common Prefix stuff
                    when 'CommonPrefixes';
                        @result[:common_prefixes] = @common_prefixes; @in_common_prefixes = false
                end
            end
        end

        class S3BucketLocationParser < AwsParser # :nodoc:
            def reset
                @result = ''
            end

            def tagend(name)
                @result = @text if name == 'LocationConstraint'
            end
        end

        class S3AclParser < AwsParser # :nodoc:
            def reset
                @result          = {:grantees=>[], :owner=>{}}
                @current_grantee = {}
            end

            def tagstart(name, attributes)
                @current_grantee = {:attributes => attributes} if name=='Grantee'
            end

            def tagend(name)
                case name
                    # service info
                    when 'ID'
                        if @xmlpath == 'AccessControlPolicy/Owner'
                            @result[:owner][:id] = @text
                        else
                            @current_grantee[:id] = @text
                        end
                    when 'DisplayName'
                        if @xmlpath == 'AccessControlPolicy/Owner'
                            @result[:owner][:display_name] = @text
                        else
                            @current_grantee[:display_name] = @text
                        end
                    when 'URI'
                        @current_grantee[:uri] = @text
                    when 'Permission'
                        @current_grantee[:permissions] = @text
                    when 'Grant'
                        @result[:grantees] << @current_grantee
                end
            end
        end

        class S3LoggingParser < AwsParser # :nodoc:
            def reset
                @result          = {:enabled => false, :targetbucket => '', :targetprefix => ''}
                @current_grantee = {}
            end

            def tagend(name)
                case name
                    # service info
                    when 'TargetBucket'
                        if @xmlpath == 'BucketLoggingStatus/LoggingEnabled'
                            @result[:targetbucket] = @text
                            @result[:enabled]      = true
                        end
                    when 'TargetPrefix'
                        if @xmlpath == 'BucketLoggingStatus/LoggingEnabled'
                            @result[:targetprefix] = @text
                            @result[:enabled]      = true
                        end
                end
            end
        end

        class S3CopyParser < AwsParser # :nodoc:
            def reset
                @result = {}
            end

            def tagend(name)
                case name
                    when 'LastModified' then
                        @result[:last_modified] = @text
                    when 'ETag' then
                        @result[:e_tag] = @text
                end
            end
        end

        #-----------------------------------------------------------------
        #      PARSERS: Non XML
        #-----------------------------------------------------------------

        class S3HttpResponseParser # :nodoc:
            attr_reader :result

            def parse(response)
                @result = response
            end

            def headers_to_string(headers)
                result = {}
                headers.each do |key, value|
                    value = value[0] if value.is_a?(Array) && value.size<2
                    result[key] = value
                end
                result
            end
        end

        class S3HttpResponseBodyParser < S3HttpResponseParser # :nodoc:
            def parse(response)
                @result = {
                        :object  => response.body,
                        :headers => headers_to_string(response.to_hash)
                }
            end
        end

        class S3HttpResponseHeadParser < S3HttpResponseParser # :nodoc:
            def parse(response)
                @result = headers_to_string(response.to_hash)
            end
        end

    end

end
