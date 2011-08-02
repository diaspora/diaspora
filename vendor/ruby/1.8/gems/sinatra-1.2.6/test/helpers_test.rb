require File.dirname(__FILE__) + '/helper'
require 'date'

class HelpersTest < Test::Unit::TestCase
  def test_default
    assert true
  end

  describe 'status' do
    setup do
      mock_app {
        get '/' do
          status 207
          nil
        end
      }
    end

    it 'sets the response status code' do
      get '/'
      assert_equal 207, response.status
    end
  end

  describe 'body' do
    it 'takes a block for defered body generation' do
      mock_app {
        get '/' do
          body { 'Hello World' }
        end
      }

      get '/'
      assert_equal 'Hello World', body
    end

    it 'takes a String, Array, or other object responding to #each' do
      mock_app {
        get '/' do
          body 'Hello World'
        end
      }

      get '/'
      assert_equal 'Hello World', body
    end
  end

  describe 'redirect' do
    it 'uses a 302 when only a path is given' do
      mock_app {
        get '/' do
          redirect '/foo'
          fail 'redirect should halt'
        end
      }

      get '/'
      assert_equal 302, status
      assert_equal '', body
      assert_equal 'http://example.org/foo', response['Location']
    end

    it 'uses the code given when specified' do
      mock_app {
        get '/' do
          redirect '/foo', 301
          fail 'redirect should halt'
        end
      }

      get '/'
      assert_equal 301, status
      assert_equal '', body
      assert_equal 'http://example.org/foo', response['Location']
    end

    it 'redirects back to request.referer when passed back' do
      mock_app {
        get '/try_redirect' do
          redirect back
        end
      }

      request = Rack::MockRequest.new(@app)
      response = request.get('/try_redirect', 'HTTP_REFERER' => '/foo')
      assert_equal 302, response.status
      assert_equal 'http://example.org/foo', response['Location']
    end

    it 'redirects using a non-standard HTTP port' do
      mock_app {
        get '/' do
          redirect '/foo'
        end
      }

      request = Rack::MockRequest.new(@app)
      response = request.get('/', 'SERVER_PORT' => '81')
      assert_equal 'http://example.org:81/foo', response['Location']
    end

    it 'redirects using a non-standard HTTPS port' do
      mock_app {
        get '/' do
          redirect '/foo'
        end
      }

      request = Rack::MockRequest.new(@app)
      response = request.get('/', 'SERVER_PORT' => '444')
      assert_equal 'http://example.org:444/foo', response['Location']
    end

    it 'works behind a reverse proxy' do
      mock_app do
        get '/' do
          redirect '/foo'
        end
      end

      request = Rack::MockRequest.new(@app)
      response = request.get('/', 'HTTP_X_FORWARDED_HOST' => 'example.com', 'SERVER_PORT' => '8080')
      assert_equal 'http://example.com/foo', response['Location']
    end

    it 'accepts absolute URIs' do
      mock_app do
        get '/' do
          redirect 'http://google.com'
          fail 'redirect should halt'
        end
      end

      get '/'
      assert_equal 302, status
      assert_equal '', body
      assert_equal 'http://google.com', response['Location']
    end

    it 'accepts absolute URIs with a different schema' do
      mock_app do
        get '/' do
          redirect 'mailto:jsmith@example.com'
          fail 'redirect should halt'
        end
      end

      get '/'
      assert_equal 302, status
      assert_equal '', body
      assert_equal 'mailto:jsmith@example.com', response['Location']
    end
  end

  describe 'error' do
    it 'sets a status code and halts' do
      mock_app {
        get '/' do
          error 501
          fail 'error should halt'
        end
      }

      get '/'
      assert_equal 501, status
      assert_equal '', body
    end

    it 'takes an optional body' do
      mock_app {
        get '/' do
          error 501, 'FAIL'
          fail 'error should halt'
        end
      }

      get '/'
      assert_equal 501, status
      assert_equal 'FAIL', body
    end

    it 'uses a 500 status code when first argument is a body' do
      mock_app {
        get '/' do
          error 'FAIL'
          fail 'error should halt'
        end
      }

      get '/'
      assert_equal 500, status
      assert_equal 'FAIL', body
    end
  end

  describe 'not_found' do
    it 'halts with a 404 status' do
      mock_app {
        get '/' do
          not_found
          fail 'not_found should halt'
        end
      }

      get '/'
      assert_equal 404, status
      assert_equal '', body
    end

    it 'does not set a X-Cascade header' do
      mock_app {
        get '/' do
          not_found
          fail 'not_found should halt'
        end
      }

      get '/'
      assert_equal 404, status
      assert_equal nil, response.headers['X-Cascade']
    end
  end

  describe 'headers' do
    it 'sets headers on the response object when given a Hash' do
      mock_app {
        get '/' do
          headers 'X-Foo' => 'bar', 'X-Baz' => 'bling'
          'kthx'
        end
      }

      get '/'
      assert ok?
      assert_equal 'bar', response['X-Foo']
      assert_equal 'bling', response['X-Baz']
      assert_equal 'kthx', body
    end

    it 'returns the response headers hash when no hash provided' do
      mock_app {
        get '/' do
          headers['X-Foo'] = 'bar'
          'kthx'
        end
      }

      get '/'
      assert ok?
      assert_equal 'bar', response['X-Foo']
    end
  end

  describe 'session' do
    it 'uses the existing rack.session' do
      mock_app {
        get '/' do
          session[:foo]
        end
      }

      get '/', {}, { 'rack.session' => { :foo => 'bar' } }
      assert_equal 'bar', body
    end

    it 'creates a new session when none provided' do
      mock_app {
        enable :sessions

        get '/' do
          assert session.empty?
          session[:foo] = 'bar'
          redirect '/hi'
        end

        get '/hi' do
          "hi #{session[:foo]}"
        end
      }

      get '/'
      follow_redirect!
      assert_equal 'hi bar', body
    end

    it 'inserts session middleware' do
      mock_app do
        enable :sessions
        get '/' do
          assert env['rack.session']
          assert env['rack.session.options']
          'ok'
        end
      end

      get '/'
      assert_body 'ok'
    end

    it 'sets a default session secret' do
      mock_app do
        enable :sessions
        get '/' do
          secret = env['rack.session.options'][:secret]
          assert secret
          assert_equal secret, settings.session_secret
          'ok'
        end
      end

      get '/'
      assert_body 'ok'
    end
  end

  describe 'mime_type' do
    include Sinatra::Helpers

    it "looks up mime types in Rack's MIME registry" do
      Rack::Mime::MIME_TYPES['.foo'] = 'application/foo'
      assert_equal 'application/foo', mime_type('foo')
      assert_equal 'application/foo', mime_type('.foo')
      assert_equal 'application/foo', mime_type(:foo)
    end

    it 'returns nil when given nil' do
      assert mime_type(nil).nil?
    end

    it 'returns nil when media type not registered' do
      assert mime_type(:bizzle).nil?
    end

    it 'returns the argument when given a media type string' do
      assert_equal 'text/plain', mime_type('text/plain')
    end
  end

  test 'Base.mime_type registers mime type' do
    mock_app {
      mime_type :foo, 'application/foo'

      get '/' do
        "foo is #{mime_type(:foo)}"
      end
    }

    get '/'
    assert_equal 'foo is application/foo', body
  end

  describe 'content_type' do
    it 'sets the Content-Type header' do
      mock_app {
        get '/' do
          content_type 'text/plain'
          'Hello World'
        end
      }

      get '/'
      assert_equal 'text/plain;charset=utf-8', response['Content-Type']
      assert_equal 'Hello World', body
    end

    it 'takes media type parameters (like charset=)' do
      mock_app {
        get '/' do
          content_type 'text/html', :charset => 'latin1'
          "<h1>Hello, World</h1>"
        end
      }

      get '/'
      assert ok?
      assert_equal 'text/html;charset=latin1', response['Content-Type']
      assert_equal "<h1>Hello, World</h1>", body
    end

    it "looks up symbols in Rack's mime types dictionary" do
      Rack::Mime::MIME_TYPES['.foo'] = 'application/foo'
      mock_app {
        get '/foo.xml' do
          content_type :foo
          "I AM FOO"
        end
      }

      get '/foo.xml'
      assert ok?
      assert_equal 'application/foo', response['Content-Type']
      assert_equal 'I AM FOO', body
    end

    it 'fails when no mime type is registered for the argument provided' do
      mock_app {
        get '/foo.xml' do
          content_type :bizzle
          "I AM FOO"
        end
      }

      assert_raise(RuntimeError) { get '/foo.xml' }
    end

    it 'only sets default charset for specific mime types' do
      tests_ran = false
      mock_app do
        mime_type :foo, 'text/foo'
        mime_type :bar, 'application/bar'
        mime_type :baz, 'application/baz'
        add_charset << mime_type(:baz)
        get '/' do
          assert_equal content_type(:txt),    'text/plain;charset=utf-8'
          assert_equal content_type(:css),    'text/css;charset=utf-8'
          assert_equal content_type(:html),   'text/html;charset=utf-8'
          assert_equal content_type(:foo),    'text/foo;charset=utf-8'
          assert_equal content_type(:xml),    'application/xml;charset=utf-8'
          assert_equal content_type(:xhtml),  'application/xhtml+xml;charset=utf-8'
          assert_equal content_type(:js),     'application/javascript;charset=utf-8'
          assert_equal content_type(:bar),    'application/bar'
          assert_equal content_type(:png),    'image/png'
          assert_equal content_type(:baz),    'application/baz;charset=utf-8'
          tests_ran = true
          "done"
        end
      end
      get '/'
      assert tests_ran
    end

    it 'handles already present params' do
      mock_app do
        get '/' do
          content_type 'foo/bar;level=1', :charset => 'utf-8'
          'ok'
        end
      end
      get '/'
      assert_equal 'foo/bar;level=1, charset=utf-8', response['Content-Type']
    end

    it 'does not add charset if present' do
      mock_app do
        get '/' do
          content_type 'text/plain;charset=utf-16'
          'ok'
        end
      end
      get '/'
      assert_equal 'text/plain;charset=utf-16', response['Content-Type']
    end
  end

  describe 'send_file' do
    setup do
      @file = File.dirname(__FILE__) + '/file.txt'
      File.open(@file, 'wb') { |io| io.write('Hello World') }
    end

    def teardown
      File.unlink @file
      @file = nil
    end

    def send_file_app(opts={})
      path = @file
      mock_app {
        get '/file.txt' do
          send_file path, opts
        end
      }
    end

    it "sends the contents of the file" do
      send_file_app
      get '/file.txt'
      assert ok?
      assert_equal 'Hello World', body
    end

    it 'sets the Content-Type response header if a mime-type can be located' do
      send_file_app
      get '/file.txt'
      assert_equal 'text/plain;charset=utf-8', response['Content-Type']
    end

    it 'sets the Content-Type response header if type option is set to a file extesion' do
      send_file_app :type => 'html'
      get '/file.txt'
      assert_equal 'text/html;charset=utf-8', response['Content-Type']
    end

    it 'sets the Content-Type response header if type option is set to a mime type' do
      send_file_app :type => 'application/octet-stream'
      get '/file.txt'
      assert_equal 'application/octet-stream', response['Content-Type']
    end

    it 'sets the Content-Length response header' do
      send_file_app
      get '/file.txt'
      assert_equal 'Hello World'.length.to_s, response['Content-Length']
    end

    it 'sets the Last-Modified response header' do
      send_file_app
      get '/file.txt'
      assert_equal File.mtime(@file).httpdate, response['Last-Modified']
    end

    it 'allows passing in a differen Last-Modified response header with :last_modified' do
      time = Time.now
      send_file_app :last_modified => time
      get '/file.txt'
      assert_equal time.httpdate, response['Last-Modified']
    end

    it "returns a 404 when not found" do
      mock_app {
        get '/' do
          send_file 'this-file-does-not-exist.txt'
        end
      }
      get '/'
      assert not_found?
    end

    it "does not set the Content-Disposition header by default" do
      send_file_app
      get '/file.txt'
      assert_nil response['Content-Disposition']
    end

    it "sets the Content-Disposition header when :disposition set to 'attachment'" do
      send_file_app :disposition => 'attachment'
      get '/file.txt'
      assert_equal 'attachment; filename="file.txt"', response['Content-Disposition']
    end

    it "sets the Content-Disposition header when :disposition set to 'inline'" do
      send_file_app :disposition => 'inline'
      get '/file.txt'
      assert_equal 'inline', response['Content-Disposition']
    end

    it "sets the Content-Disposition header when :filename provided" do
      send_file_app :filename => 'foo.txt'
      get '/file.txt'
      assert_equal 'attachment; filename="foo.txt"', response['Content-Disposition']
    end

    it "is able to send files with unkown mime type" do
      @file = File.dirname(__FILE__) + '/file.foobar'
      File.open(@file, 'wb') { |io| io.write('Hello World') }
      send_file_app
      get '/file.txt'
      assert_equal 'application/octet-stream', response['Content-Type']
    end

    it "does not override Content-Type if already set and no explicit type is given" do
      path = @file
      mock_app do
        get '/' do
          content_type :png
          send_file path
        end
      end
      get '/'
      assert_equal 'image/png', response['Content-Type']
    end

    it "does override Content-Type even if already set, if explicit type is given" do
      path = @file
      mock_app do
        get '/' do
          content_type :png
          send_file path, :type => :gif
        end
      end
      get '/'
      assert_equal 'image/gif', response['Content-Type']
    end
  end

  describe 'cache_control' do
    setup do
      mock_app do
        get '/foo' do
          cache_control :public, :no_cache, :max_age => 60.0
          'Hello World'
        end

        get '/bar' do
          cache_control :public, :no_cache
          'Hello World'
        end
      end
    end

    it 'sets the Cache-Control header' do
      get '/foo'
      assert_equal ['public', 'no-cache', 'max-age=60'], response['Cache-Control'].split(', ')
    end

    it 'last argument does not have to be a hash' do
      get '/bar'
      assert_equal ['public', 'no-cache'], response['Cache-Control'].split(', ')
    end
  end

  describe 'expires' do
    setup do
      mock_app do
        get '/foo' do
          expires 60, :public, :no_cache
          'Hello World'
        end

        get '/bar' do
          expires Time.now
        end

        get '/baz' do
          expires Time.at(0)
        end

        get '/blah' do
          obj = Object.new
          def obj.method_missing(*a, &b) 60.send(*a, &b) end
          def obj.is_a?(thing) 60.is_a?(thing) end
          expires obj, :public, :no_cache
          'Hello World'
        end
      end
    end

    it 'sets the Cache-Control header' do
      get '/foo'
      assert_equal ['public', 'no-cache', 'max-age=60'], response['Cache-Control'].split(', ')
    end

    it 'sets the Expires header' do
      get '/foo'
      assert_not_nil response['Expires']
    end

    it 'allows passing time objects' do
      get '/bar'
      assert_not_nil response['Expires']
    end

    it 'allows passing time objects' do
      get '/baz'
      assert_equal 'Thu, 01 Jan 1970 00:00:00 GMT', response['Expires']
    end

    it 'accepts values pretending to be a Numeric (like ActiveSupport::Duration)' do
      get '/blah'
      assert_equal ['public', 'no-cache', 'max-age=60'], response['Cache-Control'].split(', ')
    end
  end

  describe 'last_modified' do
    it 'ignores nil' do
      mock_app do
        get '/' do last_modified nil; 200; end
      end

      get '/'
      assert ! response['Last-Modified']
    end

    [Time.now, DateTime.now, Date.today, Time.now.to_i,
      Struct.new(:to_time).new(Time.now) ].each do |last_modified_time|
      describe "with #{last_modified_time.class.name}" do
        setup do
          mock_app do
            get '/' do
              last_modified last_modified_time
              'Boo!'
            end
          end
          wrapper = Object.new.extend Sinatra::Helpers
          @last_modified_time = wrapper.send :time_for, last_modified_time
        end

        # fixes strange missing test error when running complete test suite.
        it("does not complain about missing tests") { }

        context "when there's no If-Modified-Since header" do
          it 'sets the Last-Modified header to a valid RFC 2616 date value' do
            get '/'
            assert_equal @last_modified_time.httpdate, response['Last-Modified']
          end

          it 'conditional GET misses and returns a body' do
            get '/'
            assert_equal 200, status
            assert_equal 'Boo!', body
          end
        end

        context "when there's an invalid If-Modified-Since header" do
          it 'sets the Last-Modified header to a valid RFC 2616 date value' do
            get '/', {}, { 'HTTP_IF_MODIFIED_SINCE' => 'a really weird date' }
            assert_equal @last_modified_time.httpdate, response['Last-Modified']
          end

          it 'conditional GET misses and returns a body' do
            get '/', {}, { 'HTTP_IF_MODIFIED_SINCE' => 'a really weird date' }
            assert_equal 200, status
            assert_equal 'Boo!', body
          end
        end

        context "when the resource has been modified since the If-Modified-Since header date" do
          it 'sets the Last-Modified header to a valid RFC 2616 date value' do
            get '/', {}, { 'HTTP_IF_MODIFIED_SINCE' => (@last_modified_time - 1).httpdate }
            assert_equal @last_modified_time.httpdate, response['Last-Modified']
          end

          it 'conditional GET misses and returns a body' do
            get '/', {}, { 'HTTP_IF_MODIFIED_SINCE' => (@last_modified_time - 1).httpdate }
            assert_equal 200, status
            assert_equal 'Boo!', body
          end

          it 'does not rely on string comparison' do
            mock_app do
              get '/compare' do
                last_modified "Mon, 18 Oct 2010 20:57:11 GMT"
                "foo"
              end
            end

            get '/compare', {}, { 'HTTP_IF_MODIFIED_SINCE' => 'Sun, 26 Sep 2010 23:43:52 GMT' }
            assert_equal 200, status
            assert_equal 'foo', body
            get '/compare', {}, { 'HTTP_IF_MODIFIED_SINCE' => 'Sun, 26 Sep 2100 23:43:52 GMT' }
            assert_equal 304, status
            assert_equal '', body
          end
        end

        context "when the resource has been modified on the exact If-Modified-Since header date" do
          it 'sets the Last-Modified header to a valid RFC 2616 date value' do
            get '/', {}, { 'HTTP_IF_MODIFIED_SINCE' => @last_modified_time.httpdate }
            assert_equal @last_modified_time.httpdate, response['Last-Modified']
          end

          it 'conditional GET matches and halts' do
            get '/', {}, { 'HTTP_IF_MODIFIED_SINCE' => @last_modified_time.httpdate }
            assert_equal 304, status
            assert_equal '', body
          end
        end

        context "when the resource hasn't been modified since the If-Modified-Since header date" do
          it 'sets the Last-Modified header to a valid RFC 2616 date value' do
            get '/', {}, { 'HTTP_IF_MODIFIED_SINCE' => (@last_modified_time + 1).httpdate }
            assert_equal @last_modified_time.httpdate, response['Last-Modified']
          end

          it 'conditional GET matches and halts' do
            get '/', {}, { 'HTTP_IF_MODIFIED_SINCE' => (@last_modified_time + 1).httpdate }
            assert_equal 304, status
            assert_equal '', body
          end
        end
      end
    end
  end

  describe 'etag' do
    setup do
      mock_app {
        get '/' do
          body { 'Hello World' }
          etag 'FOO'
          'Boo!'
        end
      }
    end

    it 'sets the ETag header' do
      get '/'
      assert_equal '"FOO"', response['ETag']
    end

    it 'returns a body when conditional get misses' do
      get '/'
      assert_equal 200, status
      assert_equal 'Boo!', body
    end

    it 'halts when a conditional GET matches' do
      get '/', {}, { 'HTTP_IF_NONE_MATCH' => '"FOO"' }
      assert_equal 304, status
      assert_equal '', body
    end

    it 'should handle multiple ETag values in If-None-Match header' do
      get '/', {}, { 'HTTP_IF_NONE_MATCH' => '"BAR", *' }
      assert_equal 304, status
      assert_equal '', body
    end

    it 'uses a weak etag with the :weak option' do
      mock_app {
        get '/' do
          etag 'FOO', :weak
          "that's weak, dude."
        end
      }
      get '/'
      assert_equal 'W/"FOO"', response['ETag']
    end
  end

  describe 'back' do
    it "makes redirecting back pretty" do
      mock_app {
        get '/foo' do
          redirect back
        end
      }

      get '/foo', {}, 'HTTP_REFERER' => 'http://github.com'
      assert redirect?
      assert_equal "http://github.com", response.location
    end
  end

  describe 'uri' do
    it 'generates absolute urls' do
      mock_app { get('/') { uri }}
      get '/'
      assert_equal 'http://example.org/', body
    end

    it 'includes path_info' do
      mock_app { get('/:name') { uri }}
      get '/foo'
      assert_equal 'http://example.org/foo', body
    end

    it 'allows passing an alternative to path_info' do
      mock_app { get('/:name') { uri '/bar' }}
      get '/foo'
      assert_equal 'http://example.org/bar', body
    end

    it 'includes script_name' do
      mock_app { get('/:name') { uri '/bar' }}
      get '/foo', {}, { "SCRIPT_NAME" => '/foo' }
      assert_equal 'http://example.org/foo/bar', body
    end

    it 'handles absolute URIs' do
      mock_app { get('/') { uri 'http://google.com' }}
      get '/'
      assert_equal 'http://google.com', body
    end

    it 'handles different protocols' do
      mock_app { get('/') { uri 'mailto:jsmith@example.com' }}
      get '/'
      assert_equal 'mailto:jsmith@example.com', body
    end

    it 'is aliased to #url' do
      mock_app { get('/') { url }}
      get '/'
      assert_equal 'http://example.org/', body
    end

    it 'is aliased to #to' do
      mock_app { get('/') { to }}
      get '/'
      assert_equal 'http://example.org/', body
    end
  end

  module ::HelperOne; def one; '1'; end; end
  module ::HelperTwo; def two; '2'; end; end

  describe 'Adding new helpers' do
    it 'takes a list of modules to mix into the app' do
      mock_app {
        helpers ::HelperOne, ::HelperTwo

        get '/one' do
          one
        end

        get '/two' do
          two
        end
      }

      get '/one'
      assert_equal '1', body

      get '/two'
      assert_equal '2', body
    end

    it 'takes a block to mix into the app' do
      mock_app {
        helpers do
          def foo
            'foo'
          end
        end

        get '/' do
          foo
        end
      }

      get '/'
      assert_equal 'foo', body
    end

    it 'evaluates the block in class context so that methods can be aliased' do
      mock_app {
        helpers do
          alias_method :h, :escape_html
        end

        get '/' do
          h('42 < 43')
        end
      }

      get '/'
      assert ok?
      assert_equal '42 &lt; 43', body
    end
  end
end
