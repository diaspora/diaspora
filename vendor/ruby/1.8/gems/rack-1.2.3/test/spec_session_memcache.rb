begin
  require 'rack/session/memcache'
  require 'rack/mock'
  require 'thread'

  describe Rack::Session::Memcache do
    session_key = Rack::Session::Memcache::DEFAULT_OPTIONS[:key]
    session_match = /#{session_key}=([0-9a-fA-F]+);/
    incrementor = lambda do |env|
      env["rack.session"]["counter"] ||= 0
      env["rack.session"]["counter"] += 1
      Rack::Response.new(env["rack.session"].inspect).to_a
    end
    drop_session = proc do |env|
      env['rack.session.options'][:drop] = true
      incrementor.call(env)
    end
    renew_session = proc do |env|
      env['rack.session.options'][:renew] = true
      incrementor.call(env)
    end
    defer_session = proc do |env|
      env['rack.session.options'][:defer] = true
      incrementor.call(env)
    end

    it "faults on no connection" do
      if RUBY_VERSION < "1.9"
        lambda{
          Rack::Session::Memcache.new(incrementor, :memcache_server => 'nosuchserver')
        }.should.raise
      else
        lambda{
          Rack::Session::Memcache.new(incrementor, :memcache_server => 'nosuchserver')
        }.should.raise ArgumentError
      end
    end

    it "connects to existing server" do
      test_pool = MemCache.new(incrementor, :namespace => 'test:rack:session')
      test_pool.namespace.should.equal 'test:rack:session'
    end

    it "passes options to MemCache" do
      pool = Rack::Session::Memcache.new(incrementor, :namespace => 'test:rack:session')
      pool.pool.namespace.should.equal 'test:rack:session'
    end

    it "creates a new cookie" do
      pool = Rack::Session::Memcache.new(incrementor)
      res = Rack::MockRequest.new(pool).get("/")
      res["Set-Cookie"].should.include("#{session_key}=")
      res.body.should.equal '{"counter"=>1}'
    end

    it "determines session from a cookie" do
      pool = Rack::Session::Memcache.new(incrementor)
      req = Rack::MockRequest.new(pool)
      res = req.get("/")
      cookie = res["Set-Cookie"]
      req.get("/", "HTTP_COOKIE" => cookie).
        body.should.equal '{"counter"=>2}'
      req.get("/", "HTTP_COOKIE" => cookie).
        body.should.equal '{"counter"=>3}'
    end

    it "survives nonexistant cookies" do
      bad_cookie = "rack.session=blarghfasel"
      pool = Rack::Session::Memcache.new(incrementor)
      res = Rack::MockRequest.new(pool).
        get("/", "HTTP_COOKIE" => bad_cookie)
      res.body.should.equal '{"counter"=>1}'
      cookie = res["Set-Cookie"][session_match]
      cookie.should.not.match(/#{bad_cookie}/)
    end

    it "maintains freshness" do
      pool = Rack::Session::Memcache.new(incrementor, :expire_after => 3)
      res = Rack::MockRequest.new(pool).get('/')
      res.body.should.include '"counter"=>1'
      cookie = res["Set-Cookie"]
      res = Rack::MockRequest.new(pool).get('/', "HTTP_COOKIE" => cookie)
      res["Set-Cookie"].should.equal cookie
      res.body.should.include '"counter"=>2'
      puts 'Sleeping to expire session' if $DEBUG
      sleep 4
      res = Rack::MockRequest.new(pool).get('/', "HTTP_COOKIE" => cookie)
      res["Set-Cookie"].should.not.equal cookie
      res.body.should.include '"counter"=>1'
    end

    it "deletes cookies with :drop option" do
      pool = Rack::Session::Memcache.new(incrementor)
      req = Rack::MockRequest.new(pool)
      drop = Rack::Utils::Context.new(pool, drop_session)
      dreq = Rack::MockRequest.new(drop)

      res0 = req.get("/")
      session = (cookie = res0["Set-Cookie"])[session_match]
      res0.body.should.equal '{"counter"=>1}'

      res1 = req.get("/", "HTTP_COOKIE" => cookie)
      res1["Set-Cookie"][session_match].should.equal session
      res1.body.should.equal '{"counter"=>2}'

      res2 = dreq.get("/", "HTTP_COOKIE" => cookie)
      res2["Set-Cookie"].should.equal nil
      res2.body.should.equal '{"counter"=>3}'

      res3 = req.get("/", "HTTP_COOKIE" => cookie)
      res3["Set-Cookie"][session_match].should.not.equal session
      res3.body.should.equal '{"counter"=>1}'
    end

    it "provides new session id with :renew option" do
      pool = Rack::Session::Memcache.new(incrementor)
      req = Rack::MockRequest.new(pool)
      renew = Rack::Utils::Context.new(pool, renew_session)
      rreq = Rack::MockRequest.new(renew)

      res0 = req.get("/")
      session = (cookie = res0["Set-Cookie"])[session_match]
      res0.body.should.equal '{"counter"=>1}'

      res1 = req.get("/", "HTTP_COOKIE" => cookie)
      res1["Set-Cookie"][session_match].should.equal session
      res1.body.should.equal '{"counter"=>2}'

      res2 = rreq.get("/", "HTTP_COOKIE" => cookie)
      new_cookie = res2["Set-Cookie"]
      new_session = new_cookie[session_match]
      new_session.should.not.equal session
      res2.body.should.equal '{"counter"=>3}'

      res3 = req.get("/", "HTTP_COOKIE" => new_cookie)
      res3["Set-Cookie"][session_match].should.equal new_session
      res3.body.should.equal '{"counter"=>4}'
    end

    it "omits cookie with :defer option" do
      pool = Rack::Session::Memcache.new(incrementor)
      req = Rack::MockRequest.new(pool)
      defer = Rack::Utils::Context.new(pool, defer_session)
      dreq = Rack::MockRequest.new(defer)

      res0 = req.get("/")
      session = (cookie = res0["Set-Cookie"])[session_match]
      res0.body.should.equal '{"counter"=>1}'

      res1 = req.get("/", "HTTP_COOKIE" => cookie)
      res1["Set-Cookie"][session_match].should.equal session
      res1.body.should.equal '{"counter"=>2}'

      res2 = dreq.get("/", "HTTP_COOKIE" => cookie)
      res2["Set-Cookie"].should.equal nil
      res2.body.should.equal '{"counter"=>3}'

      res3 = req.get("/", "HTTP_COOKIE" => cookie)
      res3["Set-Cookie"][session_match].should.equal session
      res3.body.should.equal '{"counter"=>4}'
    end

    it "updates deep hashes correctly" do
      store = nil
      hash_check = proc do |env|
        session = env['rack.session']
        unless session.include? 'test'
          session.update :a => :b, :c => { :d => :e },
            :f => { :g => { :h => :i} }, 'test' => true
        else
          session[:f][:g][:h] = :j
        end
        [200, {}, session.inspect]
      end
      pool = Rack::Session::Memcache.new(hash_check)
      req = Rack::MockRequest.new(pool)

      res0 = req.get("/")
      session_id = (cookie = res0["Set-Cookie"])[session_match, 1]
      ses0 = pool.pool.get(session_id, true)

      res1 = req.get("/", "HTTP_COOKIE" => cookie)
      ses1 = pool.pool.get(session_id, true)

      ses1.should.not.equal ses0
    end

    # anyone know how to do this better?
    it "cleanly merges sessions when multithreaded" do
      unless $DEBUG
        1.should.equal 1 # fake assertion to appease the mighty bacon
        next
      end
      warn 'Running multithread test for Session::Memcache'
      pool = Rack::Session::Memcache.new(incrementor)
      req = Rack::MockRequest.new(pool)

      res = req.get('/')
      res.body.should.equal '{"counter"=>1}'
      cookie = res["Set-Cookie"]
      session_id = cookie[session_match, 1]

      delta_incrementor = lambda do |env|
        # emulate disconjoinment of threading
        env['rack.session'] = env['rack.session'].dup
        Thread.stop
        env['rack.session'][(Time.now.usec*rand).to_i] = true
        incrementor.call(env)
      end
      tses = Rack::Utils::Context.new pool, delta_incrementor
      treq = Rack::MockRequest.new(tses)
      tnum = rand(7).to_i+5
      r = Array.new(tnum) do
        Thread.new(treq) do |run|
          run.get('/', "HTTP_COOKIE" => cookie, 'rack.multithread' => true)
        end
      end.reverse.map{|t| t.run.join.value }
      r.each do |request|
        request['Set-Cookie'].should.equal cookie
        request.body.should.include '"counter"=>2'
      end

      session = pool.pool.get(session_id)
      session.size.should.equal tnum+1 # counter
      session['counter'].should.equal 2 # meeeh

      tnum = rand(7).to_i+5
      r = Array.new(tnum) do |i|
        delta_time = proc do |env|
          env['rack.session'][i]  = Time.now
          Thread.stop
          env['rack.session']     = env['rack.session'].dup
          env['rack.session'][i] -= Time.now
          incrementor.call(env)
        end
        app = Rack::Utils::Context.new pool, time_delta
        req = Rack::MockRequest.new app
        Thread.new(req) do |run|
          run.get('/', "HTTP_COOKIE" => cookie, 'rack.multithread' => true)
        end
      end.reverse.map{|t| t.run.join.value }
      r.each do |request|
        request['Set-Cookie'].should.equal cookie
        request.body.should.include '"counter"=>3'
      end

      session = pool.pool.get(session_id)
      session.size.should.be tnum+1
      session['counter'].should.be 3

      drop_counter = proc do |env|
        env['rack.session'].delete 'counter'
        env['rack.session']['foo'] = 'bar'
        [200, {'Content-Type'=>'text/plain'}, env['rack.session'].inspect]
      end
      tses = Rack::Utils::Context.new pool, drop_counter
      treq = Rack::MockRequest.new(tses)
      tnum = rand(7).to_i+5
      r = Array.new(tnum) do
        Thread.new(treq) do |run|
          run.get('/', "HTTP_COOKIE" => cookie, 'rack.multithread' => true)
        end
      end.reverse.map{|t| t.run.join.value }
      r.each do |request|
        request['Set-Cookie'].should.equal cookie
        request.body.should.include '"foo"=>"bar"'
      end

      session = pool.pool.get(session_id)
      session.size.should.be r.size+1
      session['counter'].should.be.nil?
      session['foo'].should.equal 'bar'
    end
  end
rescue RuntimeError
  $stderr.puts "Skipping Rack::Session::Memcache tests. Start memcached and try again."
rescue LoadError
  $stderr.puts "Skipping Rack::Session::Memcache tests (Memcache is required). `gem install memcache-client` and try again."
end
