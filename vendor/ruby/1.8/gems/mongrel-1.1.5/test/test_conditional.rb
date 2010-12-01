# Copyright (c) 2005 Zed A. Shaw 
# You can redistribute it and/or modify it under the same terms as Ruby.
#
# Additional work donated by contributors.  See http://mongrel.rubyforge.org/attributions.html 
# for more information.

require 'test/testhelp'

include Mongrel

class ConditionalResponseTest < Test::Unit::TestCase
  def setup
    @server = HttpServer.new('127.0.0.1', 3501)
    @server.register('/', Mongrel::DirHandler.new('.'))
    @server.run
    
    @http = Net::HTTP.new(@server.host, @server.port)

    # get the ETag and Last-Modified headers
    @path = '/README'
    res = @http.start { |http| http.get(@path) }
    assert_not_nil @etag = res['ETag']
    assert_not_nil @last_modified = res['Last-Modified']
    assert_not_nil @content_length = res['Content-Length']
  end

  def teardown
    @server.stop(true)
  end

  # status should be 304 Not Modified when If-None-Match is the matching ETag
  def test_not_modified_via_if_none_match
    assert_status_for_get_and_head Net::HTTPNotModified, 'If-None-Match' => @etag
  end

  # status should be 304 Not Modified when If-Modified-Since is the matching Last-Modified date
  def test_not_modified_via_if_modified_since
    assert_status_for_get_and_head Net::HTTPNotModified, 'If-Modified-Since' => @last_modified
  end

  # status should be 304 Not Modified when If-None-Match is the matching ETag
  # and If-Modified-Since is the matching Last-Modified date
  def test_not_modified_via_if_none_match_and_if_modified_since
    assert_status_for_get_and_head Net::HTTPNotModified, 'If-None-Match' => @etag, 'If-Modified-Since' => @last_modified
  end

  # status should be 200 OK when If-None-Match is invalid
  def test_invalid_if_none_match
    assert_status_for_get_and_head Net::HTTPOK, 'If-None-Match' => 'invalid'
    assert_status_for_get_and_head Net::HTTPOK, 'If-None-Match' => 'invalid', 'If-Modified-Since' => @last_modified
  end

  # status should be 200 OK when If-Modified-Since is invalid
  def test_invalid_if_modified_since
    assert_status_for_get_and_head Net::HTTPOK,                           'If-Modified-Since' => 'invalid'
    assert_status_for_get_and_head Net::HTTPOK, 'If-None-Match' => @etag, 'If-Modified-Since' => 'invalid'
  end

  # status should be 304 Not Modified when If-Modified-Since is greater than the Last-Modified header, but less than the system time
  def test_if_modified_since_greater_than_last_modified
    sleep 2
    last_modified_plus_1 = (Time.httpdate(@last_modified) + 1).httpdate
    assert_status_for_get_and_head Net::HTTPNotModified,                           'If-Modified-Since' => last_modified_plus_1
    assert_status_for_get_and_head Net::HTTPNotModified, 'If-None-Match' => @etag, 'If-Modified-Since' => last_modified_plus_1
  end

  # status should be 200 OK when If-Modified-Since is less than the Last-Modified header
  def test_if_modified_since_less_than_last_modified
    last_modified_minus_1 = (Time.httpdate(@last_modified) - 1).httpdate
    assert_status_for_get_and_head Net::HTTPOK,                           'If-Modified-Since' => last_modified_minus_1
    assert_status_for_get_and_head Net::HTTPOK, 'If-None-Match' => @etag, 'If-Modified-Since' => last_modified_minus_1
  end

  # status should be 200 OK when If-Modified-Since is a date in the future
  def test_future_if_modified_since
    the_future = Time.at(2**31-1).httpdate
    assert_status_for_get_and_head Net::HTTPOK,                           'If-Modified-Since' => the_future
    assert_status_for_get_and_head Net::HTTPOK, 'If-None-Match' => @etag, 'If-Modified-Since' => the_future
  end

  # status should be 200 OK when If-None-Match is a wildcard
  def test_wildcard_match
    assert_status_for_get_and_head Net::HTTPOK, 'If-None-Match' => '*'
    assert_status_for_get_and_head Net::HTTPOK, 'If-None-Match' => '*', 'If-Modified-Since' => @last_modified
  end

  private

    # assert the response status is correct for GET and HEAD
    def assert_status_for_get_and_head(response_class, headers = {})
      %w{ get head }.each do |method|
        res = @http.send(method, @path, headers)
        assert_kind_of response_class, res
        assert_equal @etag, res['ETag']
        case response_class.to_s
          when 'Net::HTTPNotModified' then
            assert_nil res['Last-Modified']
            assert_nil res['Content-Length']
          when 'Net::HTTPOK' then
            assert_equal @last_modified, res['Last-Modified']
            assert_equal @content_length, res['Content-Length']
          else
            fail "Incorrect response class: #{response_class}"
        end
      end
    end
end
