require File.dirname(__FILE__) + '/helper'

class StaticTest < Test::Unit::TestCase
  setup do
    mock_app {
      set :static, true
      set :public, File.dirname(__FILE__)
    }
  end

  it 'serves GET requests for files in the public directory' do
    get "/#{File.basename(__FILE__)}"
    assert ok?
    assert_equal File.read(__FILE__), body
    assert_equal File.size(__FILE__).to_s, response['Content-Length']
    assert response.headers.include?('Last-Modified')
  end

  it 'produces a body that can be iterated over multiple times' do
    env = Rack::MockRequest.env_for("/#{File.basename(__FILE__)}")
    status, headers, body = @app.call(env)
    buf1, buf2 = [], []
    body.each { |part| buf1 << part }
    body.each { |part| buf2 << part }
    assert_equal buf1.join, buf2.join
    assert_equal File.read(__FILE__), buf1.join
  end

  it 'sets the sinatra.static_file env variable if served' do
    env = Rack::MockRequest.env_for("/#{File.basename(__FILE__)}")
    status, headers, body = @app.call(env)
    assert_equal File.expand_path(__FILE__), env['sinatra.static_file']
  end

  it 'serves HEAD requests for files in the public directory' do
    head "/#{File.basename(__FILE__)}"
    assert ok?
    assert_equal '', body
    assert_equal File.size(__FILE__).to_s, response['Content-Length']
    assert response.headers.include?('Last-Modified')
  end

  %w[POST PUT DELETE].each do |verb|
    it "does not serve #{verb} requests" do
      send verb.downcase, "/#{File.basename(__FILE__)}"
      assert_equal 404, status
    end
  end

  it 'serves files in preference to custom routes' do
    @app.get("/#{File.basename(__FILE__)}") { 'Hello World' }
    get "/#{File.basename(__FILE__)}"
    assert ok?
    assert body != 'Hello World'
  end

  it 'does not serve directories' do
    get "/"
    assert not_found?
  end

  it 'passes to the next handler when the static option is disabled' do
    @app.set :static, false
    get "/#{File.basename(__FILE__)}"
    assert not_found?
  end

  it 'passes to the next handler when the public option is nil' do
    @app.set :public, nil
    get "/#{File.basename(__FILE__)}"
    assert not_found?
  end

  it '404s when a file is not found' do
    get "/foobarbaz.txt"
    assert not_found?
  end

  it 'serves files when .. path traverses within public directory' do
    get "/data/../#{File.basename(__FILE__)}"
    assert ok?
    assert_equal File.read(__FILE__), body
  end

  it '404s when .. path traverses outside of public directory' do
    mock_app {
      set :static, true
      set :public, File.dirname(__FILE__) + '/data'
    }
    get "/../#{File.basename(__FILE__)}"
    assert not_found?
  end

  def assert_valid_range(http_range, range, path, file)
    request = Rack::MockRequest.new(@app)
    response = request.get("/#{File.basename(path)}", 'HTTP_RANGE' => http_range)

    should_be = file[range]
    expected_range = "bytes #{range.begin}-#{range.end}/#{file.length}"

    assert_equal 206,response.status, "Should be HTTP/1.1 206 Partial content"
    assert_equal should_be.length, response.body.length, "Unexpected response length for #{http_range}"
    assert_equal should_be, response.body, "Unexpected response data for #{http_range}"
    assert_equal should_be.length.to_s, response['Content-Length'], "Incorrect Content-Length for #{http_range}"
    assert_equal expected_range, response['Content-Range'], "Incorrect Content-Range for #{http_range}"
  end

  it 'handles valid byte ranges correctly' do
    # Use the biggest file in this dir so we can test ranges > 8k bytes. (StaticFile sends in 8k chunks.)
    path = File.dirname(__FILE__) + '/helpers_test.rb'  # currently 16k bytes
    file = File.read(path)
    length = file.length
    assert length > 9000, "The test file #{path} is too short (#{length} bytes) to run these tests"

    [0..0, 42..88, 1234..1234, 100..9000, 0..(length-1), (length-1)..(length-1)].each do |range|
      assert_valid_range("bytes=#{range.begin}-#{range.end}", range, path, file)
    end

    [0, 100, length-100, length-1].each do |start|
      assert_valid_range("bytes=#{start}-", (start..length-1), path, file)
    end

    [1, 100, length-100, length-1, length].each do |range_length|
      assert_valid_range("bytes=-#{range_length}", (length-range_length..length-1), path, file)
    end

    # Some valid ranges that exceed the length of the file:
    assert_valid_range("bytes=100-999999", (100..length-1), path, file)
    assert_valid_range("bytes=100-#{length}", (100..length-1), path, file)
    assert_valid_range("bytes=-#{length}", (0..length-1), path, file)
    assert_valid_range("bytes=-#{length+1}", (0..length-1), path, file)
    assert_valid_range("bytes=-999999", (0..length-1), path, file)
  end

  it 'correctly ignores syntactically invalid range requests' do
    # ...and also ignores multi-range requests, which aren't supported yet
    ["bytes=45-40", "bytes=IV-LXVI", "octets=10-20", "bytes=-", "bytes=1-2,3-4"].each do |http_range|
      request = Rack::MockRequest.new(@app)
      response = request.get("/#{File.basename(__FILE__)}", 'HTTP_RANGE' => http_range)

      assert_equal 200,response.status, "Invalid range '#{http_range}' should be ignored"
      assert_equal nil,response['Content-Range'], "Invalid range '#{http_range}' should be ignored"
    end
  end

  it 'returns error 416 for unsatisfiable range requests' do
    # An unsatisfiable request is one that specifies a start that's at or past the end of the file.
    length = File.read(__FILE__).length
    ["bytes=888888-", "bytes=888888-999999", "bytes=#{length}-#{length}"].each do |http_range|
      request = Rack::MockRequest.new(@app)
      response = request.get("/#{File.basename(__FILE__)}", 'HTTP_RANGE' => http_range)

      assert_equal 416,response.status, "Unsatisfiable range '#{http_range}' should return 416"
      assert_equal "bytes */#{length}",response['Content-Range'], "416 response should include actual length"
    end
  end
end
