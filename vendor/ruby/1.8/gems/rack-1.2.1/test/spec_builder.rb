require 'rack/builder'
require 'rack/mock'
require 'rack/showexceptions'
require 'rack/urlmap'

class NothingMiddleware
  def initialize(app)
    @app = app
  end
  def call(env)
    @@env = env
    response = @app.call(env)
    response
  end
  def self.env
    @@env
  end
end

describe Rack::Builder do
  it "supports mapping" do
    app = Rack::Builder.new do
      map '/' do |outer_env|
        run lambda { |inner_env| [200, {}, ['root']] }
      end
      map '/sub' do
        run lambda { |inner_env| [200, {}, ['sub']] }
      end
    end.to_app
    Rack::MockRequest.new(app).get("/").body.to_s.should.equal 'root'
    Rack::MockRequest.new(app).get("/sub").body.to_s.should.equal 'sub'
  end

  it "doesn't dupe env even when mapping" do
    app = Rack::Builder.new do
      use NothingMiddleware
      map '/' do |outer_env|
        run lambda { |inner_env|
          inner_env['new_key'] = 'new_value'
          [200, {}, ['root']]
        }
      end
    end.to_app
    Rack::MockRequest.new(app).get("/").body.to_s.should.equal 'root'
    NothingMiddleware.env['new_key'].should.equal 'new_value'
  end

  it "chains apps by default" do
    app = Rack::Builder.new do
      use Rack::ShowExceptions
      run lambda { |env| raise "bzzzt" }
    end.to_app

    Rack::MockRequest.new(app).get("/").should.be.server_error
    Rack::MockRequest.new(app).get("/").should.be.server_error
    Rack::MockRequest.new(app).get("/").should.be.server_error
  end

  it "has implicit #to_app" do
    app = Rack::Builder.new do
      use Rack::ShowExceptions
      run lambda { |env| raise "bzzzt" }
    end

    Rack::MockRequest.new(app).get("/").should.be.server_error
    Rack::MockRequest.new(app).get("/").should.be.server_error
    Rack::MockRequest.new(app).get("/").should.be.server_error
  end

  it "supports blocks on use" do
    app = Rack::Builder.new do
      use Rack::ShowExceptions
      use Rack::Auth::Basic do |username, password|
        'secret' == password
      end

      run lambda { |env| [200, {}, ['Hi Boss']] }
    end

    response = Rack::MockRequest.new(app).get("/")
    response.should.be.client_error
    response.status.should.equal 401

    # with auth...
    response = Rack::MockRequest.new(app).get("/",
        'HTTP_AUTHORIZATION' => 'Basic ' + ["joe:secret"].pack("m*"))
    response.status.should.equal 200
    response.body.to_s.should.equal 'Hi Boss'
  end

  it "has explicit #to_app" do
    app = Rack::Builder.app do
      use Rack::ShowExceptions
      run lambda { |env| raise "bzzzt" }
    end

    Rack::MockRequest.new(app).get("/").should.be.server_error
    Rack::MockRequest.new(app).get("/").should.be.server_error
    Rack::MockRequest.new(app).get("/").should.be.server_error
  end

  should "initialize apps once" do
    app = Rack::Builder.new do
      class AppClass
        def initialize
          @called = 0
        end
        def call(env)
          raise "bzzzt"  if @called > 0
        @called += 1
          [200, {'Content-Type' => 'text/plain'}, ['OK']]
        end
      end

      use Rack::ShowExceptions
      run AppClass.new
    end

    Rack::MockRequest.new(app).get("/").status.should.equal 200
    Rack::MockRequest.new(app).get("/").should.be.server_error
  end

end
