require File.expand_path('../test_helper', __FILE__)

class NetHTTPClientTest < Test::Unit::TestCase

  def setup
    @consumer = OAuth::Consumer.new('consumer_key_86cad9', '5888bf0345e5d237')
    @token = OAuth::Token.new('token_411a7f', '3196ffd991c8ebdb')
    @request_uri = URI.parse('http://example.com/test?key=value')
    @request_parameters = { 'key' => 'value' }
    @nonce = 225579211881198842005988698334675835446
    @timestamp = "1199645624"
    @http = Net::HTTP.new(@request_uri.host, @request_uri.port)
  end

  def test_that_using_auth_headers_on_get_requests_works
    request = Net::HTTP::Get.new(@request_uri.path + "?" + request_parameters_to_s)
    request.oauth!(@http, @consumer, @token, {:nonce => @nonce, :timestamp => @timestamp})

    assert_equal 'GET', request.method
    assert_equal '/test?key=value', request.path
    correct_sorted_params = "oauth_nonce=\"225579211881198842005988698334675835446\", oauth_signature_method=\"HMAC-SHA1\", oauth_token=\"token_411a7f\", oauth_timestamp=\"1199645624\", oauth_consumer_key=\"consumer_key_86cad9\", oauth_signature=\"1oO2izFav1GP4kEH2EskwXkCRFg%3D\", oauth_version=\"1.0\""
    auth_intro, auth_params = request['authorization'].split(' ', 2)
    assert_equal auth_intro, 'OAuth'
    assert_matching_headers correct_sorted_params, request['authorization']
  end

  def test_that_using_auth_headers_on_get_requests_works_with_plaintext
    require 'oauth/signature/plaintext'
    c = OAuth::Consumer.new('consumer_key_86cad9', '5888bf0345e5d237',{
      :signature_method => 'PLAINTEXT'
    })
    request = Net::HTTP::Get.new(@request_uri.path + "?" + request_parameters_to_s)
    request.oauth!(@http, c, @token, {:nonce => @nonce, :timestamp => @timestamp, :signature_method => 'PLAINTEXT'})

    assert_equal 'GET', request.method
    assert_equal '/test?key=value', request.path
    assert_matching_headers "oauth_nonce=\"225579211881198842005988698334675835446\", oauth_signature_method=\"PLAINTEXT\", oauth_token=\"token_411a7f\", oauth_timestamp=\"1199645624\", oauth_consumer_key=\"consumer_key_86cad9\", oauth_signature=\"5888bf0345e5d237%263196ffd991c8ebdb\", oauth_version=\"1.0\"", request['authorization']
  end

  def test_that_using_auth_headers_on_post_requests_works
    request = Net::HTTP::Post.new(@request_uri.path)
    request.set_form_data( @request_parameters )
    request.oauth!(@http, @consumer, @token, {:nonce => @nonce, :timestamp => @timestamp})

    assert_equal 'POST', request.method
    assert_equal '/test', request.path
    assert_equal 'key=value', request.body
    correct_sorted_params = "oauth_nonce=\"225579211881198842005988698334675835446\", oauth_signature_method=\"HMAC-SHA1\", oauth_token=\"token_411a7f\", oauth_timestamp=\"1199645624\", oauth_consumer_key=\"consumer_key_86cad9\", oauth_signature=\"26g7wHTtNO6ZWJaLltcueppHYiI%3D\", oauth_version=\"1.0\""
    assert_matching_headers correct_sorted_params, request['authorization']
  end

  def test_that_using_auth_headers_on_post_requests_with_data_works
    request = Net::HTTP::Post.new(@request_uri.path)
    request.body = "data"
    request.content_type = 'text/ascii'
    request.oauth!(@http, @consumer, @token, {:nonce => @nonce, :timestamp => @timestamp})

    assert_equal 'POST', request.method
    assert_equal '/test', request.path
    assert_equal 'data', request.body
    assert_equal 'text/ascii', request.content_type
    assert_matching_headers "oauth_nonce=\"225579211881198842005988698334675835446\", oauth_body_hash=\"oXyaqmHoChv3HQ2FCvTluqmAC70%3D\", oauth_signature_method=\"HMAC-SHA1\", oauth_token=\"token_411a7f\", oauth_timestamp=\"1199645624\", oauth_consumer_key=\"consumer_key_86cad9\", oauth_signature=\"0DA6pGTapdHSqC15RZelY5rNLDw%3D\", oauth_version=\"1.0\"", request['authorization']
  end

  def test_that_body_hash_is_obmitted_when_no_algorithm_is_defined
    request = Net::HTTP::Post.new(@request_uri.path)
    request.body = "data"
    request.content_type = 'text/ascii'
    request.oauth!(@http, @consumer, @token, {:nonce => @nonce, :timestamp => @timestamp, :signature_method => 'plaintext'})

    assert_equal 'POST', request.method
    assert_equal '/test', request.path
    assert_equal 'data', request.body
    assert_equal 'text/ascii', request.content_type
    assert_matching_headers "oauth_nonce=\"225579211881198842005988698334675835446\", oauth_signature_method=\"plaintext\", oauth_token=\"token_411a7f\", oauth_timestamp=\"1199645624\", oauth_consumer_key=\"consumer_key_86cad9\", oauth_signature=\"5888bf0345e5d237%263196ffd991c8ebdb\", oauth_version=\"1.0\"", request['authorization']
  end

  def test_that_version_is_added_to_existing_user_agent
    request = Net::HTTP::Post.new(@request_uri.path)
    request['User-Agent'] = "MyApp"
    request.set_form_data( @request_parameters )
    request.oauth!(@http, @consumer, @token, {:nonce => @nonce, :timestamp => @timestamp})

    assert_equal "MyApp (OAuth gem v#{OAuth::VERSION})", request['User-Agent']
  end

  def test_that_version_is_set_when_no_user_agent
    request = Net::HTTP::Post.new(@request_uri.path)
    request.set_form_data( @request_parameters )
    request.oauth!(@http, @consumer, @token, {:nonce => @nonce, :timestamp => @timestamp})

    assert_equal "OAuth gem v#{OAuth::VERSION}", request['User-Agent']
  end

  def test_that_using_get_params_works
    request = Net::HTTP::Get.new(@request_uri.path + "?" + request_parameters_to_s)
    request.oauth!(@http, @consumer, @token, {:scheme => 'query_string', :nonce => @nonce, :timestamp => @timestamp})

    assert_equal 'GET', request.method
    uri = URI.parse(request.path)
    assert_equal '/test', uri.path
    assert_equal nil, uri.fragment
    assert_equal "key=value&oauth_consumer_key=consumer_key_86cad9&oauth_nonce=225579211881198842005988698334675835446&oauth_signature=1oO2izFav1GP4kEH2EskwXkCRFg%3D&oauth_signature_method=HMAC-SHA1&oauth_timestamp=1199645624&oauth_token=token_411a7f&oauth_version=1.0", uri.query.split("&").sort.join("&")
    assert_equal nil, request['authorization']
  end

  def test_that_using_get_params_works_with_plaintext
    request = Net::HTTP::Get.new(@request_uri.path + "?" + request_parameters_to_s)
    request.oauth!(@http, @consumer, @token, {:scheme => 'query_string', :nonce => @nonce, :timestamp => @timestamp, :signature_method => 'PLAINTEXT'})

    assert_equal 'GET', request.method
    uri = URI.parse(request.path)
    assert_equal '/test', uri.path
    assert_equal nil, uri.fragment
    assert_equal "key=value&oauth_consumer_key=consumer_key_86cad9&oauth_nonce=225579211881198842005988698334675835446&oauth_signature=5888bf0345e5d237%263196ffd991c8ebdb&oauth_signature_method=PLAINTEXT&oauth_timestamp=1199645624&oauth_token=token_411a7f&oauth_version=1.0", uri.query.split("&").sort.join("&")
    assert_equal nil, request['authorization']
  end

  def test_that_using_post_params_works
    request = Net::HTTP::Post.new(@request_uri.path)
    request.set_form_data( @request_parameters )
    request.oauth!(@http, @consumer, @token, {:scheme => 'body', :nonce => @nonce, :timestamp => @timestamp})

    assert_equal 'POST', request.method
    assert_equal '/test', request.path
    assert_equal "key=value&oauth_consumer_key=consumer_key_86cad9&oauth_nonce=225579211881198842005988698334675835446&oauth_signature=26g7wHTtNO6ZWJaLltcueppHYiI%3d&oauth_signature_method=HMAC-SHA1&oauth_timestamp=1199645624&oauth_token=token_411a7f&oauth_version=1.0", request.body.split("&").sort.join("&")
    assert_equal nil, request['authorization']
  end

  def test_that_using_post_params_works_with_plaintext
    request = Net::HTTP::Post.new(@request_uri.path)
    request.set_form_data( @request_parameters )
    request.oauth!(@http, @consumer, @token, {:scheme => 'body', :nonce => @nonce, :timestamp => @timestamp, :signature_method => 'PLAINTEXT'})

    assert_equal 'POST', request.method
    assert_equal '/test', request.path
    assert_equal "key=value&oauth_consumer_key=consumer_key_86cad9&oauth_nonce=225579211881198842005988698334675835446&oauth_signature=5888bf0345e5d237%263196ffd991c8ebdb&oauth_signature_method=PLAINTEXT&oauth_timestamp=1199645624&oauth_token=token_411a7f&oauth_version=1.0", request.body.split("&").sort.join("&")
    assert_equal nil, request['authorization']
  end

  def test_that_using_post_with_uri_params_works
    request = Net::HTTP::Post.new(@request_uri.path + "?" + request_parameters_to_s)
    request.set_form_data( {} ) # just to make sure we have a correct mime type and thus no body hash
    request.oauth!(@http, @consumer, @token, {:scheme => 'query_string', :nonce => @nonce, :timestamp => @timestamp})

    assert_equal 'POST', request.method
    uri = URI.parse(request.path)
    assert_equal '/test', uri.path
    assert_equal nil, uri.fragment
    assert_equal "key=value&oauth_consumer_key=consumer_key_86cad9&oauth_nonce=225579211881198842005988698334675835446&oauth_signature=26g7wHTtNO6ZWJaLltcueppHYiI%3D&oauth_signature_method=HMAC-SHA1&oauth_timestamp=1199645624&oauth_token=token_411a7f&oauth_version=1.0", uri.query.split("&").sort.join('&')
    assert_equal "", request.body
    assert_equal nil, request['authorization']
  end

  def test_that_using_post_with_uri_and_form_params_works
    request = Net::HTTP::Post.new(@request_uri.path + "?" + request_parameters_to_s)
    request.set_form_data( { 'key2' => 'value2' } )
    request.oauth!(@http, @consumer, @token, {:scheme => :query_string, :nonce => @nonce, :timestamp => @timestamp})

    assert_equal 'POST', request.method
    uri = URI.parse(request.path)
    assert_equal '/test', uri.path
    assert_equal nil, uri.fragment
    assert_equal "key=value&oauth_consumer_key=consumer_key_86cad9&oauth_nonce=225579211881198842005988698334675835446&oauth_signature=4kSU8Zd1blWo3W6qJH7eaRTMkg0%3D&oauth_signature_method=HMAC-SHA1&oauth_timestamp=1199645624&oauth_token=token_411a7f&oauth_version=1.0", uri.query.split("&").sort.join('&')
    assert_equal "key2=value2", request.body
    assert_equal nil, request['authorization']
  end

  def test_that_using_post_with_uri_and_data_works
    request = Net::HTTP::Post.new(@request_uri.path + "?" + request_parameters_to_s)
    request.body = "data"
    request.content_type = 'text/ascii'
    request.oauth!(@http, @consumer, @token, {:scheme => :query_string, :nonce => @nonce, :timestamp => @timestamp})

    assert_equal 'POST', request.method
    uri = URI.parse(request.path)
    assert_equal '/test', uri.path
    assert_equal nil, uri.fragment
    assert_equal "data", request.body
    assert_equal 'text/ascii', request.content_type
    assert_equal "key=value&oauth_body_hash=oXyaqmHoChv3HQ2FCvTluqmAC70%3D&oauth_consumer_key=consumer_key_86cad9&oauth_nonce=225579211881198842005988698334675835446&oauth_signature=MHRKU42iVHU4Ke9kBUDa9Zw6IAM%3D&oauth_signature_method=HMAC-SHA1&oauth_timestamp=1199645624&oauth_token=token_411a7f&oauth_version=1.0", uri.query.split("&").sort.join('&')
    assert_equal nil, request['authorization']
  end


  def test_example_from_specs
    consumer=OAuth::Consumer.new("dpf43f3p2l4k3l03","kd94hf93k423kf44")
    token = OAuth::Token.new('nnch734d00sl2jdk', 'pfkkdhi9sl3r4s00')
    request_uri = URI.parse('http://photos.example.net/photos?file=vacation.jpg&size=original')
    nonce = 'kllo9940pd9333jh'
    timestamp = "1191242096"
    http = Net::HTTP.new(request_uri.host, request_uri.port)

    request = Net::HTTP::Get.new(request_uri.path + "?" + request_uri.query)
    signature_base_string=request.signature_base_string(http, consumer, token, {:nonce => nonce, :timestamp => timestamp})
    assert_equal 'GET&http%3A%2F%2Fphotos.example.net%2Fphotos&file%3Dvacation.jpg%26oauth_consumer_key%3Ddpf43f3p2l4k3l03%26oauth_nonce%3Dkllo9940pd9333jh%26oauth_signature_method%3DHMAC-SHA1%26oauth_timestamp%3D1191242096%26oauth_token%3Dnnch734d00sl2jdk%26oauth_version%3D1.0%26size%3Doriginal',signature_base_string

#    request = Net::HTTP::Get.new(request_uri.path + "?" + request_uri.query)
    request.oauth!(http, consumer, token, {:nonce => nonce, :timestamp => timestamp, :realm=>"http://photos.example.net/"})

    assert_equal 'GET', request.method
    correct_sorted_params = 'oauth_nonce="kllo9940pd9333jh", oauth_signature_method="HMAC-SHA1", oauth_token="nnch734d00sl2jdk", oauth_timestamp="1191242096", oauth_consumer_key="dpf43f3p2l4k3l03", oauth_signature="tR3%2BTy81lMeYAr%2FFid0kMTYa%2FWM%3D", oauth_version="1.0"'.split(', ').sort
    correct_sorted_params.unshift 'OAuth realm="http://photos.example.net/"'
    assert_equal correct_sorted_params, request['authorization'].split(', ').sort
  end

  def test_step_by_step_token_request
    consumer=OAuth::Consumer.new(
        "key",
        "secret")
    request_uri = URI.parse('http://term.ie/oauth/example/request_token.php')
    nonce = rand(2**128).to_s
    timestamp = Time.now.to_i.to_s
    http = Net::HTTP.new(request_uri.host, request_uri.port)

    request = Net::HTTP::Get.new(request_uri.path)
    signature_base_string=request.signature_base_string(http, consumer, nil, {:scheme=>:query_string,:nonce => nonce, :timestamp => timestamp})
    assert_equal "GET&http%3A%2F%2Fterm.ie%2Foauth%2Fexample%2Frequest_token.php&oauth_consumer_key%3Dkey%26oauth_nonce%3D#{nonce}%26oauth_signature_method%3DHMAC-SHA1%26oauth_timestamp%3D#{timestamp}%26oauth_version%3D1.0",signature_base_string

#    request = Net::HTTP::Get.new(request_uri.path)
    request.oauth!(http, consumer, nil, {:scheme=>:query_string,:nonce => nonce, :timestamp => timestamp})
    assert_equal 'GET', request.method
    assert_nil request.body
    assert_nil request['authorization']
#    assert_equal 'OAuth oauth_nonce="kllo9940pd9333jh", oauth_signature_method="HMAC-SHA1", oauth_token="", oauth_timestamp="'+timestamp+'", oauth_consumer_key="key", oauth_signature="tR3%2BTy81lMeYAr%2FFid0kMTYa%2FWM%3D", oauth_version="1.0"', request['authorization']

    response=http.request(request)
    assert_equal "200",response.code
#    assert_equal request['authorization'],response.body
    assert_equal "oauth_token=requestkey&oauth_token_secret=requestsecret",response.body
  end

  def test_that_put_bodies_signed
    request = Net::HTTP::Put.new(@request_uri.path)
    request.body = "<?xml version=\"1.0\"?><foo><bar>baz</bar></foo>"
    request["Content-Type"] = "application/xml"
    signature_base_string=request.signature_base_string(@http, @consumer, nil, { :nonce => @nonce, :timestamp => @timestamp })
    assert_equal "PUT&http%3A%2F%2Fexample.com%2Ftest&oauth_body_hash%3DDvAa1AWdFoH9K%252B%252F2AHm3f6wH27k%253D%26oauth_consumer_key%3Dconsumer_key_86cad9%26oauth_nonce%3D225579211881198842005988698334675835446%26oauth_signature_method%3DHMAC-SHA1%26oauth_timestamp%3D1199645624%26oauth_version%3D1.0", signature_base_string
  end

  def test_that_put_bodies_not_signed_even_if_form_urlencoded
    request = Net::HTTP::Put.new(@request_uri.path)
    request.set_form_data( { 'key2' => 'value2' } )
    signature_base_string=request.signature_base_string(@http, @consumer, nil, { :nonce => @nonce, :timestamp => @timestamp })
    assert_equal "PUT&http%3A%2F%2Fexample.com%2Ftest&oauth_consumer_key%3Dconsumer_key_86cad9%26oauth_nonce%3D225579211881198842005988698334675835446%26oauth_signature_method%3DHMAC-SHA1%26oauth_timestamp%3D1199645624%26oauth_version%3D1.0", signature_base_string
  end

  def test_that_post_bodies_signed_if_form_urlencoded
    request = Net::HTTP::Post.new(@request_uri.path)
    request.set_form_data( { 'key2' => 'value2' } )
    signature_base_string=request.signature_base_string(@http, @consumer, nil, { :nonce => @nonce, :timestamp => @timestamp })
    assert_equal "POST&http%3A%2F%2Fexample.com%2Ftest&key2%3Dvalue2%26oauth_consumer_key%3Dconsumer_key_86cad9%26oauth_nonce%3D225579211881198842005988698334675835446%26oauth_signature_method%3DHMAC-SHA1%26oauth_timestamp%3D1199645624%26oauth_version%3D1.0", signature_base_string
  end

  def test_that_post_bodies_signed_if_other_content_type
    request = Net::HTTP::Post.new(@request_uri.path)
    request.body = "<?xml version=\"1.0\"?><foo><bar>baz</bar></foo>"
    request["Content-Type"] = "application/xml"
    signature_base_string=request.signature_base_string(@http, @consumer, nil, { :nonce => @nonce, :timestamp => @timestamp })
    assert_equal "POST&http%3A%2F%2Fexample.com%2Ftest&oauth_body_hash%3DDvAa1AWdFoH9K%252B%252F2AHm3f6wH27k%253D%26oauth_consumer_key%3Dconsumer_key_86cad9%26oauth_nonce%3D225579211881198842005988698334675835446%26oauth_signature_method%3DHMAC-SHA1%26oauth_timestamp%3D1199645624%26oauth_version%3D1.0", signature_base_string
  end

  def test_that_site_address_is_not_modified_in_place
    options = { :site => 'http://twitter.com', :request_endpoint => 'http://api.twitter.com' }
    request = Net::HTTP::Get.new(@request_uri.path + "?" + request_parameters_to_s)
    request.oauth!(@http, @consumer, @token, options)
    assert_equal "http://twitter.com", options[:site]
    assert_equal "http://api.twitter.com", options[:request_endpoint]
  end

  protected

    def request_parameters_to_s
      @request_parameters.map { |k,v| "#{k}=#{v}" }.join("&")
    end

end
