WebMock
=======

Library for stubbing and setting expectations on HTTP requests in Ruby.

Features
--------

* Stubbing HTTP requests at low http client lib level (no need to change tests when you change HTTP library)
* Setting and verifying expectations on HTTP requests
* Matching requests based on method, URI, headers and body
* Smart matching of the same URIs in different representations (also encoded and non encoded forms)
* Smart matching of the same headers in different representations.
* Support for Test::Unit
* Support for RSpec 1.x and RSpec 2.x

Supported HTTP libraries
------------------------

* Net::HTTP and libraries based on Net::HTTP (i.e RightHttpConnection, REST Client, HTTParty)
* HTTPClient
* Patron
* EM-HTTP-Request
* Curb (currently only Curb::Easy)

##Installation

	gem install webmock --source http://gemcutter.org

### or to install the latest development version from github master

	git clone http://github.com/bblimke/webmock.git
	cd webmock
	rake install

### Test::Unit 

Add the following code to `test/test_helper.rb`

	require 'webmock/test_unit'

### RSpec
	
Add the following code to `spec/spec_helper`:

	require 'webmock/rspec'

### Cucumber

Add the following code to `features/support/env.rb`

	require 'webmock/cucumber'

You can also use WebMock outside a test framework:

	require 'webmock'
	include WebMock::API

## Examples



## Stubbing


### Stubbed request based on uri only and with the default response

	 stub_request(:any, "www.example.com")

	 Net::HTTP.get("www.example.com", "/")    # ===> Success

### Stubbing requests based on method, uri, body and headers

	stub_request(:post, "www.example.com").with(:body => "abc", :headers => { 'Content-Length' => 3 })

	uri = URI.parse("http://www.example.com/")
    req = Net::HTTP::Post.new(uri.path)
	req['Content-Length'] = 3
    res = Net::HTTP.start(uri.host, uri.port) {|http|
      http.request(req, "abc")
    }    # ===> Success

### Matching request body and headers against regular expressions

	stub_request(:post, "www.example.com").
	  with(:body => /^.*world$/, :headers => {"Content-Type" => /image\/.+/}).to_return(:body => "abc")

	uri = URI.parse('http://www.example.com/')
    req = Net::HTTP::Post.new(uri.path)
	req['Content-Type'] = 'image/png'
    res = Net::HTTP.start(uri.host, uri.port) {|http|
      http.request(req, 'hello world')
    }    # ===> Success
    
### Matching request body against a hash. Body can be URL-Encoded, JSON or XML.

	stub_http_request(:post, "www.example.com").
		with(:body => {:data => {:a => '1', :b => 'five'}})

	RestClient.post('www.example.com', "data[a]=1&data[b]=five", 
	  :content_type => 'application/x-www-form-urlencoded')    # ===> Success
	
	RestClient.post('www.example.com', '{"data":{"a":"1","b":"five"}}', 
	  :content_type => 'application/json')    # ===> Success
	
	RestClient.post('www.example.com', '<data a="1" b="five" />', 
	  :content_type => 'application/xml' )    # ===> Success

### Matching custom request headers

    stub_request(:any, "www.example.com").with(:headers=>{ 'Header-Name' => 'Header-Value' })

	uri = URI.parse('http://www.example.com/')
    req = Net::HTTP::Post.new(uri.path)
	req['Header-Name'] = 'Header-Value'
    res = Net::HTTP.start(uri.host, uri.port) {|http|
      http.request(req, 'abc')
    }    # ===> Success

### Matching multiple headers with the same name

	stub_http_request(:get, 'www.example.com').with(:headers => {'Accept' => ['image/jpeg', 'image/png'] })
	
	req = Net::HTTP::Get.new("/")  
	req['Accept'] = ['image/png']
	req.add_field('Accept', 'image/jpeg')
	Net::HTTP.start("www.example.com") {|http|  http.request(req) } # ===> Success

### Matching requests against provided block

	stub_request(:post, "www.example.com").with { |request| request.body == "abc" }
	RestClient.post('www.example.com', 'abc')    # ===> Success
	
### Request with basic authentication

    stub_request(:get, "user:pass@www.example.com")

    Net::HTTP.start('www.example.com') {|http|
      req = Net::HTTP::Get.new('/')
      req.basic_auth 'user', 'pass'
      http.request(req)
    }  # ===> Success

### Matching uris using regular expressions

	 stub_request(:any, /.*example.*/)

	 Net::HTTP.get('www.example.com', '/') # ===> Success	
	 
### Matching query params using hash	 

	 stub_http_request(:get, "www.example.com").with(:query => {"a" => ["b", "c"]})
	 
	 RestClient.get("http://www.example.com/?a[]=b&a[]=c") # ===> Success	
	 
### Stubbing with custom response

	stub_request(:any, "www.example.com").to_return(:body => "abc", :status => 200,  :headers => { 'Content-Length' => 3 } )
	
	Net::HTTP.get("www.example.com", '/')    # ===> "abc"

### Response with body specified as IO object

	File.open('/tmp/response_body.txt', 'w') { |f| f.puts 'abc' }

	stub_request(:any, "www.example.com").to_return(:body => File.new('/tmp/response_body.txt'), :status => 200)

	Net::HTTP.get('www.example.com', '/')    # ===> "abc\n"
	
### Response with custom status message

	stub_request(:any, "www.example.com").to_return(:status => [500, "Internal Server Error"])

	req = Net::HTTP::Get.new("/")
	Net::HTTP.start("www.example.com") { |http| http.request(req) }.message # ===> "Internal Server Error"
		
### Replaying raw responses recorded with `curl -is`

	`curl -is www.example.com > /tmp/example_curl_-is_output.txt`
	raw_response_file = File.new("/tmp/example_curl_-is_output.txt")

   from file

	stub_request(:get, "www.example.com").to_return(raw_response_file)

   or string

	stub_request(:get, "www.example.com").to_return(raw_response_file.read)

### Responses dynamically evaluated from block

    stub_request(:any, 'www.example.net').
      to_return { |request| {:body => request.body} }

    RestClient.post('www.example.net', 'abc')    # ===> "abc\n"

### Responses dynamically evaluated from lambda

    stub_request(:any, 'www.example.net').
      to_return(lambda { |request| {:body => request.body} })

    RestClient.post('www.example.net', 'abc')    # ===> "abc\n"	       

### Dynamically evaluated raw responses recorded with `curl -is`

    `curl -is www.example.com > /tmp/www.example.com.txt`
    stub_request(:get, "www.example.com").to_return(lambda { |request| File.new("/tmp/#{request.uri.host.to_s}.txt" }))

### Responses with dynamically evaluated parts

    stub_request(:any, 'www.example.net').
      to_return(:body => lambda { |request| request.body })

    RestClient.post('www.example.net', 'abc')    # ===> "abc\n"	

### Raising errors

#### Exception declared by class

	stub_request(:any, 'www.example.net').to_raise(StandardError)

    RestClient.post('www.example.net', 'abc')    # ===> StandardError
    
#### or by exception instance

    stub_request(:any, 'www.example.net').to_raise(StandardError.new("some error"))

#### or by string
    
    stub_request(:any, 'www.example.net').to_raise("some error")

### Raising timeout errors

	stub_request(:any, 'www.example.net').to_timeout

	RestClient.post('www.example.net', 'abc')    # ===> RestClient::RequestTimeout	

### Multiple responses for repeated requests

	stub_request(:get, "www.example.com").to_return({:body => "abc"}, {:body => "def"})
	Net::HTTP.get('www.example.com', '/')    # ===> "abc\n"
	Net::HTTP.get('www.example.com', '/')    # ===> "def\n"
	
	#after all responses are used the last response will be returned infinitely
	
	Net::HTTP.get('www.example.com', '/')    # ===> "def\n" 

### Multiple responses using chained `to_return()`, `to_raise()` or `to_timeout` declarations

	stub_request(:get, "www.example.com").
		to_return({:body => "abc"}).then.  #then() is just a syntactic sugar
		to_return({:body => "def"}).then.
		to_raise(MyException)
	Net::HTTP.get('www.example.com', '/')    # ===> "abc\n"
	Net::HTTP.get('www.example.com', '/')    # ===> "def\n"
	Net::HTTP.get('www.example.com', '/')    # ===> MyException raised

### Specifying number of times given response should be returned

	stub_request(:get, "www.example.com").
		to_return({:body => "abc"}).times(2).then.
		to_return({:body => "def"})

	Net::HTTP.get('www.example.com', '/')    # ===> "abc\n"
	Net::HTTP.get('www.example.com', '/')    # ===> "abc\n"
	Net::HTTP.get('www.example.com', '/')    # ===> "def\n"


### Real requests to network can be allowed or disabled

	WebMock.allow_net_connect!

	stub_request(:any, "www.example.com").to_return(:body => "abc")

	Net::HTTP.get('www.example.com', '/')    # ===> "abc"
	
	Net::HTTP.get('www.something.com', '/') # ===> /.+Something.+/
	
	WebMock.disable_net_connect!
	
	Net::HTTP.get('www.something.com', '/')    # ===> Failure

### External requests can be disabled while allowing localhost
	
	WebMock.disable_net_connect!(:allow_localhost => true)
	
	Net::HTTP.get('www.something.com', '/')   # ===> Failure
	
	Net::HTTP.get('localhost:9887', '/')      # ===> Allowed. Perhaps to Selenium?

### External requests can be disabled while allowing any hostname

	WebMock.disable_net_connect!(:allow => "www.example.org")

	Net::HTTP.get('www.something.com', '/')   # ===> Failure

	Net::HTTP.get('www.example.org', '/')      # ===> Allowed.

## Connecting on Net::HTTP.start

HTTP protocol has 3 steps: connect, request and response (or 4 with close). Most Ruby HTTP client libraries
treat connect as a part of request step, with the exception of `Net::HTTP` which
allows opening connection to the server separately to the request, by using `Net::HTTP.start`.

WebMock API was also designed with connect being part of request step, and it only allows stubbing
requests, not connections. When `Net::HTTP.start` is called, WebMock doesn't know yet whether
a request is stubbed or not. WebMock by default delays a connection until the request is invoked,
so when there is no request, `Net::HTTP.start` doesn't do anything.
**This means that WebMock breaks the Net::HTTP behaviour by default!**

To workaround this issue, WebMock offers `:net_http_connect_on_start` option,
which can be passed to `WebMock.allow_net_connect!` and `WebMock#disable_net_connect!` methods, i.e.

	WebMock.allow_net_connect!(:net_http_connect_on_start => true)

This forces WebMock Net::HTTP adapter to always connect on `Net::HTTP.start`.

## Setting Expectations

### Setting expectations in Test::Unit
	require 'webmock/test_unit'

    stub_request(:any, "www.example.com")

	uri = URI.parse('http://www.example.com/')
    req = Net::HTTP::Post.new(uri.path)
	req['Content-Length'] = 3
    res = Net::HTTP.start(uri.host, uri.port) {|http|
      http.request(req, 'abc')
    }

	assert_requested :post, "http://www.example.com",
	  :headers => {'Content-Length' => 3}, :body => "abc", :times => 1    # ===> Success
	
	assert_not_requested :get, "http://www.something.com"    # ===> Success

	assert_requested(:post, "http://www.example.com", :times => 1) { |req| req.body == "abc" }

### Expecting real (not stubbed) requests

	WebMock.allow_net_connect!
	
	Net::HTTP.get('www.example.com', '/')    # ===> Success

	assert_requested :get, "http://www.example.com"    # ===> Success


### Setting expectations in RSpec
 This style is borrowed from [fakeweb-matcher](http://github.com/freelancing-god/fakeweb-matcher)

	require 'webmock/rspec'

	WebMock.should have_requested(:get, "www.example.com").with(:body => "abc", :headers => {'Content-Length' => 3}).twice
	
	WebMock.should_not have_requested(:get, "www.something.com")
	
	WebMock.should have_requested(:post, "www.example.com").with { |req| req.body == "abc" }
	
	WebMock.should have_requested(:get, "www.example.com").with(:query => {"a" => ["b", "c"]}) 

	WebMock.should have_requested(:get, "www.example.com").
	  with(:body => {"a" => ["b", "c"]}, :headers => 'Content-Type' => 'application/json')

### Different way of setting expectations in RSpec

	a_request(:post, "www.example.com").with(:body => "abc", :headers => {'Content-Length' => 3}).should have_been_made.once

	a_request(:post, "www.something.com").should have_been_made.times(3)

	a_request(:any, "www.example.com").should_not have_been_made

	a_request(:post, "www.example.com").with { |req| req.body == "abc" }.should have_been_made

	a_request(:get, "www.example.com").with(:query => {"a" => ["b", "c"]}).should have_been_made

	a_request(:post, "www.example.com").
	  with(:body => {"a" => ["b", "c"]}, :headers => 'Content-Type' => 'application/json').should have_been_made

## Clearing stubs and request history

If you want to reset all current stubs and history of requests use `WebMock.reset!`

	stub_request(:any, "www.example.com")

	Net::HTTP.get('www.example.com', '/')    # ===> Success

	WebMock.reset!

	Net::HTTP.get('www.example.com', '/')    # ===> Failure

	assert_not_requested :get, "www.example.com"    # ===> Success


## Matching requests

An executed request matches stubbed request if it passes following criteria:

  When request URI matches stubbed request URI string or Regexp pattern<br/>
  And request method is the same as stubbed request method or stubbed request method is :any<br/>
  And request body is the same as stubbed request body or stubbed request body is not specified<br/>
  And request headers match stubbed request headers, or stubbed request headers match a subset of request headers, or stubbed request headers are not specified<br/>
  And request matches provided block or block is not provided

## Precedence of stubs

Always the last declared stub matching the request will be applied i.e:

	stub_request(:get, "www.example.com").to_return(:body => "abc")
	stub_request(:get, "www.example.com").to_return(:body => "def")

	Net::HTTP.get('www.example.com', '/')   # ====> "def"

## Matching URIs

WebMock will match all different representations of the same URI. 

I.e all the following representations of the URI are equal:

    "www.example.com"
    "www.example.com/"
    "www.example.com:80"
    "www.example.com:80/"
    "http://www.example.com"
    "http://www.example.com/"
    "http://www.example.com:80"
    "http://www.example.com:80/"
	
The following URIs with basic authentication are also equal for WebMock

	"a b:pass@www.example.com"
	"a b:pass@www.example.com/"
	"a b:pass@www.example.com:80"
	"a b:pass@www.example.com:80/"
	"http://a b:pass@www.example.com"
	"http://a b:pass@www.example.com/"
	"http://a b:pass@www.example.com:80"
	"http://a b:pass@www.example.com:80/"
	"a%20b:pass@www.example.com"
	"a%20b:pass@www.example.com/"
	"a%20b:pass@www.example.com:80"
	"a%20b:pass@www.example.com:80/"
	"http://a%20b:pass@www.example.com"
	"http://a%20b:pass@www.example.com/"
	"http://a%20b:pass@www.example.com:80"
	"http://a%20b:pass@www.example.com:80/"	

or these

	"www.example.com/my path/?a=my param&b=c"
	"www.example.com/my%20path/?a=my%20param&b=c"
	"www.example.com:80/my path/?a=my param&b=c"
	"www.example.com:80/my%20path/?a=my%20param&b=c"
	"http://www.example.com/my path/?a=my param&b=c"
	"http://www.example.com/my%20path/?a=my%20param&b=c"
	"http://www.example.com:80/my path/?a=my param&b=c"
	"http://www.example.com:80/my%20path/?a=my%20param&b=c"


If you provide Regexp to match URI, WebMock will try to match it against every valid form of the same url.

I.e `/.*my param.*/` will match `www.example.com/my%20path` because it is equivalent of `www.example.com/my path`


## Matching headers

WebMock will match request headers against stubbed request headers in the following situations:

1. Stubbed request has headers specified and request headers are the same as stubbed headers <br/>
i.e stubbed headers: `{ 'Header1' => 'Value1', 'Header1' => 'Value1' }`, requested: `{ 'Header1' => 'Value1', 'Header1' => 'Value1' }`

2. Stubbed request has headers specified and stubbed request headers are a subset of request headers <br/>
i.e stubbed headers: `{ 'Header1' => 'Value1'  }`, requested: `{ 'Header1' => 'Value1', 'Header1' => 'Value1' }`

3. Stubbed request has no headers <br/>
i.e stubbed headers: `nil`, requested: `{ 'Header1' => 'Value1', 'Header1' => 'Value1' }`

WebMock normalises headers and treats all forms of same headers as equal:
i.e the following two sets of headers are equal:

`{ "Header1" => "value1", :content_length => 123, :X_CuStOm_hEAder => :value }`

`{ :header1 => "value1",  "Content-Length" => 123, "x-cuSTOM-HeAder" => "value" }`

## Recording real requests and responses and replaying them later

To record your application's real HTTP interactions and replay them later in tests you can use [VCR](http://github.com/myronmarston/vcr) with WebMock.

## Request callbacks

####WebMock can invoke callbacks stubbed or real requests:

    WebMock.after_request do |request_signature, response|
      puts "Request #{request_signature} was made and #{response} was returned"
    end

#### invoke callbacks for real requests only and except requests made with Patron

    WebMock.after_request(:except => [:patron], :real_requests_only => true)  do |request_signature, response|
      puts "Request #{request_signature} was made and #{response} was returned"
    end

## Bugs and Issues

Please submit them here [http://github.com/bblimke/webmock/issues](http://github.com/bblimke/webmock/issues)

## Suggestions

If you have any suggestions on how to improve WebMock please send an email to the mailing list [groups.google.com/group/webmock-users](http://groups.google.com/group/webmock-users)

I'm particularly interested in how the DSL could be improved.

## Credits

The initial lines of this project were written during New Bamboo [Hack Day](http://blog.new-bamboo.co.uk/2009/11/13/hackday-results)
Thanks to my fellow [Bambinos](http://new-bamboo.co.uk/) for all the great suggestions!

People who submitted patches and new features or suggested improvements. Many thanks to these people:

* Ben Pickles
* Mark Evans
* Ivan Vega
* Piotr Usewicz
* Nick Plante
* Nick Quaranto
* Diego E. "Flameeyes" Pettenò
* Niels Meersschaert
* Mack Earnhardt
* Arvicco
* Sergio Gil
* Jeffrey Jones
* Tekin Suleyman
* Tom Ward
* Nadim Bitar
* Myron Marston
* Sam Phillips
* Jose Angel Cortinas
* Razic
* Steve Tooke
* Nathaniel Bibler
* Martyn Loughran
* Muness Alrubaie
* Charles Li
* Ryan Bigg
* Pete Higgins
* Hans de Graaff
* Alastair Brunton
* Sam Stokes
* Eugene Bolshakov

## Background

Thank you Fakeweb! This library was inspired by [FakeWeb](fakeweb.rubyforge.org).
I imported some solutions from that project to WebMock. I also copied some code i.e Net:HTTP adapter. 
Fakeweb architecture unfortunately didn't allow me to extend it easily with the features I needed.
I also preferred some things to work differently i.e request stub precedence.

## Copyright

Copyright (c) 2009-2010 Bartosz Blimke. See LICENSE for details.
