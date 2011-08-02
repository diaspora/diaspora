require File.dirname(__FILE__) + '/helper'

class BeforeFilterTest < Test::Unit::TestCase
  it "executes filters in the order defined" do
    count = 0
    mock_app do
      get('/') { 'Hello World' }
      before {
        assert_equal 0, count
        count = 1
      }
      before {
        assert_equal 1, count
        count = 2
      }
    end

    get '/'
    assert ok?
    assert_equal 2, count
    assert_equal 'Hello World', body
  end

  it "can modify the request" do
    mock_app {
      get('/foo') { 'foo' }
      get('/bar') { 'bar' }
      before { request.path_info = '/bar' }
    }

    get '/foo'
    assert ok?
    assert_equal 'bar', body
  end

  it "can modify instance variables available to routes" do
    mock_app {
      before { @foo = 'bar' }
      get('/foo') { @foo }
    }

    get '/foo'
    assert ok?
    assert_equal 'bar', body
  end

  it "allows redirects" do
    mock_app {
      before { redirect '/bar' }
      get('/foo') do
        fail 'before block should have halted processing'
        'ORLY?!'
      end
    }

    get '/foo'
    assert redirect?
    assert_equal 'http://example.org/bar', response['Location']
    assert_equal '', body
  end

  it "does not modify the response with its return value" do
    mock_app {
      before { 'Hello World!' }
      get '/foo' do
        assert_equal [], response.body
        'cool'
      end
    }

    get '/foo'
    assert ok?
    assert_equal 'cool', body
  end

  it "does modify the response with halt" do
    mock_app {
      before { halt 302, 'Hi' }
      get '/foo' do
        "should not happen"
      end
    }

    get '/foo'
    assert_equal 302, response.status
    assert_equal 'Hi', body
  end

  it "gives you access to params" do
    mock_app {
      before { @foo = params['foo'] }
      get('/foo') { @foo }
    }

    get '/foo?foo=cool'
    assert ok?
    assert_equal 'cool', body
  end

  it "runs filters defined in superclasses" do
    base = Class.new(Sinatra::Base)
    base.before { @foo = 'hello from superclass' }

    mock_app(base) {
      get('/foo') { @foo }
    }

    get '/foo'
    assert_equal 'hello from superclass', body
  end

  it 'does not run before filter when serving static files' do
    ran_filter = false
    mock_app {
      before { ran_filter = true }
      set :static, true
      set :public, File.dirname(__FILE__)
    }
    get "/#{File.basename(__FILE__)}"
    assert ok?
    assert_equal File.read(__FILE__), body
    assert !ran_filter
  end

  it 'takes an optional route pattern' do
    ran_filter = false
    mock_app do
      before("/b*") { ran_filter = true }
      get('/foo') { }
      get('/bar') { }
    end
    get '/foo'
    assert !ran_filter
    get '/bar'
    assert ran_filter
  end

  it 'generates block arguments from route pattern' do
    subpath = nil
    mock_app do
      before("/foo/:sub") { |s| subpath = s }
      get('/foo/*') { }
    end
    get '/foo/bar'
    assert_equal subpath, 'bar'
  end
end

class AfterFilterTest < Test::Unit::TestCase
  it "executes filters in the order defined" do
    invoked = 0
    mock_app do
      before   { invoked = 2 }
      get('/') { invoked += 2 }
      after    { invoked *= 2 }
    end

    get '/'
    assert ok?

    assert_equal 8, invoked
  end

  it "executes filters in the order defined" do
    count = 0
    mock_app do
      get('/') { 'Hello World' }
      after {
        assert_equal 0, count
        count = 1
      }
      after {
        assert_equal 1, count
        count = 2
      }
    end

    get '/'
    assert ok?
    assert_equal 2, count
    assert_equal 'Hello World', body
  end

  it "allows redirects" do
    mock_app {
      get('/foo') { 'ORLY' }
      after { redirect '/bar' }
    }

    get '/foo'
    assert redirect?
    assert_equal 'http://example.org/bar', response['Location']
    assert_equal '', body
  end

  it "does not modify the response with its return value" do
    mock_app {
      get('/foo') { 'cool' }
      after { 'Hello World!' }
    }

    get '/foo'
    assert ok?
    assert_equal 'cool', body
  end

  it "does modify the response with halt" do
    mock_app {
      get '/foo' do
        "should not be returned"
      end
      after { halt 302, 'Hi' }
    }

    get '/foo'
    assert_equal 302, response.status
    assert_equal 'Hi', body
  end

  it "runs filters defined in superclasses" do
    count = 2
    base = Class.new(Sinatra::Base)
    base.after { count *= 2 }
    mock_app(base) {
      get('/foo') { count += 2 }
    }

    get '/foo'
    assert_equal 8, count
  end

  it 'does not run after filter when serving static files' do
    ran_filter = false
    mock_app {
      after { ran_filter = true }
      set :static, true
      set :public, File.dirname(__FILE__)
    }
    get "/#{File.basename(__FILE__)}"
    assert ok?
    assert_equal File.read(__FILE__), body
    assert !ran_filter
  end

  it 'takes an optional route pattern' do
    ran_filter = false
    mock_app do
      after("/b*") { ran_filter = true }
      get('/foo') { }
      get('/bar') { }
    end
    get '/foo'
    assert !ran_filter
    get '/bar'
    assert ran_filter
  end

  it 'changes to path_info from a pattern matching before filter are respoected when routing' do
    mock_app do
      before('/foo') { request.path_info = '/bar' }
      get('/bar') { 'blah' }
    end
    get '/foo'
    assert ok?
    assert_equal 'blah', body
  end

  it 'generates block arguments from route pattern' do
    subpath = nil
    mock_app do
      after("/foo/:sub") { |s| subpath = s }
      get('/foo/*') { }
    end
    get '/foo/bar'
    assert_equal subpath, 'bar'
  end

  it 'is possible to access url params from the route param' do
    ran = false
    mock_app do
      get('/foo/*') { }
      before('/foo/:sub') do
        assert_equal params[:sub], 'bar'
        ran = true
      end
    end
    get '/foo/bar'
    assert ran
  end

  it 'is possible to apply host_name conditions to before filters with no path' do
    ran = false
    mock_app do
      before(:host_name => 'example.com') { ran = true }
      get('/') { 'welcome' }
    end
    get '/', {}, { 'HTTP_HOST' => 'example.org' }
    assert !ran
    get '/', {}, { 'HTTP_HOST' => 'example.com' }
    assert ran
  end

  it 'is possible to apply host_name conditions to before filters with a path' do
    ran = false
    mock_app do
      before('/foo', :host_name => 'example.com') { ran = true }
      get('/') { 'welcome' }
    end
    get '/', {}, { 'HTTP_HOST' => 'example.com' }
    assert !ran
    get '/foo', {}, { 'HTTP_HOST' => 'example.org' }
    assert !ran
    get '/foo', {}, { 'HTTP_HOST' => 'example.com' }
    assert ran
  end

  it 'is possible to apply host_name conditions to after filters with no path' do
    ran = false
    mock_app do
      after(:host_name => 'example.com') { ran = true }
      get('/') { 'welcome' }
    end
    get '/', {}, { 'HTTP_HOST' => 'example.org' }
    assert !ran
    get '/', {}, { 'HTTP_HOST' => 'example.com' }
    assert ran
  end

  it 'is possible to apply host_name conditions to after filters with a path' do
    ran = false
    mock_app do
      after('/foo', :host_name => 'example.com') { ran = true }
      get('/') { 'welcome' }
    end
    get '/', {}, { 'HTTP_HOST' => 'example.com' }
    assert !ran
    get '/foo', {}, { 'HTTP_HOST' => 'example.org' }
    assert !ran
    get '/foo', {}, { 'HTTP_HOST' => 'example.com' }
    assert ran
  end

  it 'is possible to apply user_agent conditions to before filters with no path' do
    ran = false
    mock_app do
      before(:user_agent => /foo/) { ran = true }
      get('/') { 'welcome' }
    end
    get '/', {}, { 'HTTP_USER_AGENT' => 'bar' }
    assert !ran
    get '/', {}, { 'HTTP_USER_AGENT' => 'foo' }
    assert ran
  end

  it 'is possible to apply user_agent conditions to before filters with a path' do
    ran = false
    mock_app do
      before('/foo', :user_agent => /foo/) { ran = true }
      get('/') { 'welcome' }
    end
    get '/', {}, { 'HTTP_USER_AGENT' => 'foo' }
    assert !ran
    get '/foo', {}, { 'HTTP_USER_AGENT' => 'bar' }
    assert !ran
    get '/foo', {}, { 'HTTP_USER_AGENT' => 'foo' }
    assert ran
  end

  it 'is possible to apply user_agent conditions to after filters with no path' do
    ran = false
    mock_app do
      after(:user_agent => /foo/) { ran = true }
      get('/') { 'welcome' }
    end
    get '/', {}, { 'HTTP_USER_AGENT' => 'bar' }
    assert !ran
    get '/', {}, { 'HTTP_USER_AGENT' => 'foo' }
    assert ran
  end

  it 'is possible to apply user_agent conditions to before filters with a path' do
    ran = false
    mock_app do
      after('/foo', :user_agent => /foo/) { ran = true }
      get('/') { 'welcome' }
    end
    get '/', {}, { 'HTTP_USER_AGENT' => 'foo' }
    assert !ran
    get '/foo', {}, { 'HTTP_USER_AGENT' => 'bar' }
    assert !ran
    get '/foo', {}, { 'HTTP_USER_AGENT' => 'foo' }
    assert ran
  end
end
