require File.expand_path('../../test_helper', __FILE__)

module Integration
  class ConsumerTest < Test::Unit::TestCase
    def setup
      @consumer=OAuth::Consumer.new(
          'consumer_key_86cad9', '5888bf0345e5d237',
          {
          :site=>"http://blabla.bla",
          :proxy=>"http://user:password@proxy.bla:8080",
          :request_token_path=>"/oauth/example/request_token.php",
          :access_token_path=>"/oauth/example/access_token.php",
          :authorize_path=>"/oauth/example/authorize.php",
          :scheme=>:header,
          :http_method=>:get
          })
      @token = OAuth::ConsumerToken.new(@consumer,'token_411a7f', '3196ffd991c8ebdb')
      @request_uri = URI.parse('http://example.com/test?key=value')
      @request_parameters = { 'key' => 'value' }
      @nonce = 225579211881198842005988698334675835446
      @timestamp = "1199645624"
      @consumer.http=Net::HTTP.new(@request_uri.host, @request_uri.port)
    end

    def test_that_signing_auth_headers_on_get_requests_works
      request = Net::HTTP::Get.new(@request_uri.path + "?" + request_parameters_to_s)
      @token.sign!(request, {:nonce => @nonce, :timestamp => @timestamp})

      assert_equal 'GET', request.method
      assert_equal '/test?key=value', request.path
      assert_equal "OAuth oauth_nonce=\"225579211881198842005988698334675835446\", oauth_signature_method=\"HMAC-SHA1\", oauth_token=\"token_411a7f\", oauth_timestamp=\"1199645624\", oauth_consumer_key=\"consumer_key_86cad9\", oauth_signature=\"1oO2izFav1GP4kEH2EskwXkCRFg%3D\", oauth_version=\"1.0\"".split(', ').sort, request['authorization'].split(', ').sort
    end

    def test_that_setting_signature_method_on_consumer_effects_signing
      require 'oauth/signature/plaintext'
      request = Net::HTTP::Get.new(@request_uri.path)
      consumer = @consumer.dup
      consumer.options[:signature_method] = 'PLAINTEXT'
      token = OAuth::ConsumerToken.new(consumer, 'token_411a7f', '3196ffd991c8ebdb')
      token.sign!(request, {:nonce => @nonce, :timestamp => @timestamp})

      assert_no_match( /oauth_signature_method="HMAC-SHA1"/, request['authorization'])
      assert_match(    /oauth_signature_method="PLAINTEXT"/, request['authorization'])
    end

    def test_that_setting_signature_method_on_consumer_effects_signature_base_string
      require 'oauth/signature/plaintext'
      request = Net::HTTP::Get.new(@request_uri.path)
      consumer = @consumer.dup
      consumer.options[:signature_method] = 'PLAINTEXT'

      request = Net::HTTP::Get.new('/')
      signature_base_string = consumer.signature_base_string(request)

      assert_no_match( /HMAC-SHA1/, signature_base_string)
      assert_equal( "#{consumer.secret}&", signature_base_string)
    end

    def test_that_plaintext_signature_works
      # Invalid test because server expects double-escaped signature
      require 'oauth/signature/plaintext'
      # consumer = OAuth::Consumer.new("key", "secret",
      #   :site => "http://term.ie", :signature_method => 'PLAINTEXT')
      # access_token = OAuth::AccessToken.new(consumer, 'accesskey', 'accesssecret')
      # response = access_token.get("/oauth/example/echo_api.php?echo=hello")

      # assert_equal 'echo=hello', response.body
    end

    def test_that_signing_auth_headers_on_post_requests_works
      request = Net::HTTP::Post.new(@request_uri.path)
      request.set_form_data( @request_parameters )
      @token.sign!(request, {:nonce => @nonce, :timestamp => @timestamp})
  #    assert_equal "",request.oauth_helper.signature_base_string

      assert_equal 'POST', request.method
      assert_equal '/test', request.path
      assert_equal 'key=value', request.body
      assert_equal "OAuth oauth_nonce=\"225579211881198842005988698334675835446\", oauth_signature_method=\"HMAC-SHA1\", oauth_token=\"token_411a7f\", oauth_timestamp=\"1199645624\", oauth_consumer_key=\"consumer_key_86cad9\", oauth_signature=\"26g7wHTtNO6ZWJaLltcueppHYiI%3D\", oauth_version=\"1.0\"".split(', ').sort, request['authorization'].split(', ').sort
    end

    def test_that_signing_post_params_works
      request = Net::HTTP::Post.new(@request_uri.path)
      request.set_form_data( @request_parameters )
      @token.sign!(request, {:scheme => 'body', :nonce => @nonce, :timestamp => @timestamp})

      assert_equal 'POST', request.method
      assert_equal '/test', request.path
      assert_equal "key=value&oauth_consumer_key=consumer_key_86cad9&oauth_nonce=225579211881198842005988698334675835446&oauth_signature=26g7wHTtNO6ZWJaLltcueppHYiI%3d&oauth_signature_method=HMAC-SHA1&oauth_timestamp=1199645624&oauth_token=token_411a7f&oauth_version=1.0", request.body.split("&").sort.join("&")
      assert_equal nil, request['authorization']
    end

    def test_that_using_auth_headers_on_get_on_create_signed_requests_works
      request=@consumer.create_signed_request(:get,@request_uri.path+ "?" + request_parameters_to_s,@token,{:nonce => @nonce, :timestamp => @timestamp},@request_parameters)

      assert_equal 'GET', request.method
      assert_equal '/test?key=value', request.path
      assert_equal "OAuth oauth_nonce=\"225579211881198842005988698334675835446\", oauth_signature_method=\"HMAC-SHA1\", oauth_token=\"token_411a7f\", oauth_timestamp=\"1199645624\", oauth_consumer_key=\"consumer_key_86cad9\", oauth_signature=\"1oO2izFav1GP4kEH2EskwXkCRFg%3D\", oauth_version=\"1.0\"".split(', ').sort, request['authorization'].split(', ').sort
    end

    def test_that_using_auth_headers_on_post_on_create_signed_requests_works
      request=@consumer.create_signed_request(:post,@request_uri.path,@token,{:nonce => @nonce, :timestamp => @timestamp},@request_parameters,{})
      assert_equal 'POST', request.method
      assert_equal '/test', request.path
      assert_equal 'key=value', request.body
      assert_equal "OAuth oauth_nonce=\"225579211881198842005988698334675835446\", oauth_signature_method=\"HMAC-SHA1\", oauth_token=\"token_411a7f\", oauth_timestamp=\"1199645624\", oauth_consumer_key=\"consumer_key_86cad9\", oauth_signature=\"26g7wHTtNO6ZWJaLltcueppHYiI%3D\", oauth_version=\"1.0\"".split(', ').sort, request['authorization'].split(', ').sort
    end

    def test_that_signing_post_params_works_2
      request=@consumer.create_signed_request(:post,@request_uri.path,@token,{:scheme => 'body', :nonce => @nonce, :timestamp => @timestamp},@request_parameters,{})

      assert_equal 'POST', request.method
      assert_equal '/test', request.path
      assert_equal "key=value&oauth_consumer_key=consumer_key_86cad9&oauth_nonce=225579211881198842005988698334675835446&oauth_signature=26g7wHTtNO6ZWJaLltcueppHYiI%3d&oauth_signature_method=HMAC-SHA1&oauth_timestamp=1199645624&oauth_token=token_411a7f&oauth_version=1.0", request.body.split("&").sort.join("&")
      assert_equal nil, request['authorization']
    end

    def test_step_by_step_token_request
      @consumer=OAuth::Consumer.new(
          "key",
          "secret",
          {
          :site=>"http://term.ie",
          :request_token_path=>"/oauth/example/request_token.php",
          :access_token_path=>"/oauth/example/access_token.php",
          :authorize_path=>"/oauth/example/authorize.php",
          :scheme=>:header
          })
      options={:nonce=>'nonce',:timestamp=>Time.now.to_i.to_s}

      request = Net::HTTP::Get.new("/oauth/example/request_token.php")
      signature_base_string=@consumer.signature_base_string(request,nil,options)
      assert_equal "GET&http%3A%2F%2Fterm.ie%2Foauth%2Fexample%2Frequest_token.php&oauth_consumer_key%3Dkey%26oauth_nonce%3D#{options[:nonce]}%26oauth_signature_method%3DHMAC-SHA1%26oauth_timestamp%3D#{options[:timestamp]}%26oauth_version%3D1.0",signature_base_string
      @consumer.sign!(request, nil,options)

      assert_equal 'GET', request.method
      assert_equal nil, request.body
      response=@consumer.http.request(request)
      assert_equal "200",response.code
      assert_equal "oauth_token=requestkey&oauth_token_secret=requestsecret",response.body
    end

    def test_get_token_sequence
      @consumer=OAuth::Consumer.new(
          "key",
          "secret",
          {
          :site=>"http://term.ie",
          :request_token_path=>"/oauth/example/request_token.php",
          :access_token_path=>"/oauth/example/access_token.php",
          :authorize_path=>"/oauth/example/authorize.php"
          })
      assert_equal "http://term.ie/oauth/example/request_token.php",@consumer.request_token_url
      assert_equal "http://term.ie/oauth/example/access_token.php",@consumer.access_token_url

      assert !@consumer.request_token_url?, "Should not use fully qualified request token url"
      assert !@consumer.access_token_url?, "Should not use fully qualified access token url"
      assert !@consumer.authorize_url?, "Should not use fully qualified url"

      @request_token=@consumer.get_request_token
      assert_not_nil @request_token
      assert_equal "requestkey",@request_token.token
      assert_equal "requestsecret",@request_token.secret
      assert_equal "http://term.ie/oauth/example/authorize.php?oauth_token=requestkey",@request_token.authorize_url

      @access_token=@request_token.get_access_token
      assert_not_nil @access_token
      assert_equal "accesskey",@access_token.token
      assert_equal "accesssecret",@access_token.secret

      @response=@access_token.get("/oauth/example/echo_api.php?ok=hello&test=this")
      assert_not_nil @response
      assert_equal "200",@response.code
      assert_equal( "ok=hello&test=this",@response.body)

      @response=@access_token.post("/oauth/example/echo_api.php",{'ok'=>'hello','test'=>'this'})
      assert_not_nil @response
      assert_equal "200",@response.code
      assert_equal( "ok=hello&test=this",@response.body)
    end

    def test_get_token_sequence_using_fqdn
      @consumer=OAuth::Consumer.new(
          "key",
          "secret",
          {
          :site=>"http://term.ie",
          :request_token_url=>"http://term.ie/oauth/example/request_token.php",
          :access_token_url=>"http://term.ie/oauth/example/access_token.php",
          :authorize_url=>"http://term.ie/oauth/example/authorize.php"
          })
      assert_equal "http://term.ie/oauth/example/request_token.php",@consumer.request_token_url
      assert_equal "http://term.ie/oauth/example/access_token.php",@consumer.access_token_url

      assert @consumer.request_token_url?, "Should use fully qualified request token url"
      assert @consumer.access_token_url?, "Should use fully qualified access token url"
      assert @consumer.authorize_url?, "Should use fully qualified url"

      @request_token=@consumer.get_request_token
      assert_not_nil @request_token
      assert_equal "requestkey",@request_token.token
      assert_equal "requestsecret",@request_token.secret
      assert_equal "http://term.ie/oauth/example/authorize.php?oauth_token=requestkey",@request_token.authorize_url

      @access_token=@request_token.get_access_token
      assert_not_nil @access_token
      assert_equal "accesskey",@access_token.token
      assert_equal "accesssecret",@access_token.secret

      @response=@access_token.get("/oauth/example/echo_api.php?ok=hello&test=this")
      assert_not_nil @response
      assert_equal "200",@response.code
      assert_equal( "ok=hello&test=this",@response.body)

      @response=@access_token.post("/oauth/example/echo_api.php",{'ok'=>'hello','test'=>'this'})
      assert_not_nil @response
      assert_equal "200",@response.code
      assert_equal( "ok=hello&test=this",@response.body)
    end


    # This test does an actual https request (the result doesn't matter)
    # to initialize the same way as get_request_token does. Can be any
    # site that supports https.
    #
    # It also generates "warning: using default DH parameters." which I
    # don't know how to get rid of
  #  def test_serialization_with_https
  #    consumer = OAuth::Consumer.new('token', 'secret', :site => 'https://plazes.net')
  #    consumer.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  #    consumer.http.get('/')
  #
  #    assert_nothing_raised do
  #      # Specifically this should not raise TypeError: no marshal_dump
  #      # is defined for class OpenSSL::SSL::SSLContext
  #      Marshal.dump(consumer)
  #    end
  #  end
  #
    def test_get_request_token_with_custom_arguments
      @consumer=OAuth::Consumer.new(
          "key",
          "secret",
          {
          :site=>"http://term.ie",
          :request_token_path=>"/oauth/example/request_token.php",
          :access_token_path=>"/oauth/example/access_token.php",
          :authorize_path=>"/oauth/example/authorize.php"
          })


      debug = ""
      @consumer.http.set_debug_output(debug)

      # get_request_token should receive our custom request_options and *arguments parameters from get_request_token.
      @consumer.get_request_token({}, {:scope => "http://www.google.com/calendar/feeds http://picasaweb.google.com/data"})

      # Because this is a POST request, create_http_request should take the first element of *arguments
      # and turn it into URL-encoded data in the body of the POST.
      assert_match( /^<- "scope=http%3a%2f%2fwww.google.com%2fcalendar%2ffeeds%20http%3a%2f%2fpicasaweb.google.com%2fdata"/,
        debug)
    end

    def test_post_with_body_stream
      @consumer=OAuth::Consumer.new(
          "key",
          "secret",
          {
          :site=>"http://term.ie",
          :request_token_path=>"/oauth/example/request_token.php",
          :access_token_path=>"/oauth/example/access_token.php",
          :authorize_path=>"/oauth/example/authorize.php"
          })


      @request_token=@consumer.get_request_token
      @access_token=@request_token.get_access_token

      request_body_string = "Hello, hello, hello"
      request_body_stream = StringIO.new( request_body_string )

      @response=@access_token.post("/oauth/example/echo_api.php",request_body_stream)
      assert_not_nil @response
      assert_equal "200",@response.code

      request_body_file = File.open(__FILE__)

      @response=@access_token.post("/oauth/example/echo_api.php",request_body_file)
      assert_not_nil @response
      assert_equal "200",@response.code

      # unfortunately I don't know of a way to test that the body data was received correctly since the test server at http://term.ie
      # echos back any non-oauth parameters but not the body.  However, this does test that the request is still correctly signed
      # (including the Content-Length header) and that the server received Content-Length bytes of body since it won't process the
      # request & respond until the full body length is received.
    end

    private

    def request_parameters_to_s
      @request_parameters.map { |k,v| "#{k}=#{v}" }.join("&")
    end
  end
end
