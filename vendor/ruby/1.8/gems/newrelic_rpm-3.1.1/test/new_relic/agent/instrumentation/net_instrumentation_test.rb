unless ENV['FAST_TESTS']
  require File.expand_path(File.join(File.dirname(__FILE__),'..','..','..','test_helper'))

  class NewRelic::Agent::Instrumentation::NetInstrumentationTest < Test::Unit::TestCase
    include NewRelic::Agent::Instrumentation::ControllerInstrumentation
    def setup
      NewRelic::Agent.manual_start
      @engine = NewRelic::Agent.instance.stats_engine
      @engine.clear_stats
    end

    def metrics_without_gc
      @engine.metrics - ['GC/cumulative']
    end

    private :metrics_without_gc

    def test_get
      url = URI.parse('http://www.google.com/index.html')
      res = Net::HTTP.start(url.host, url.port) {|http|
        http.get('/index.html')
      }
      assert_match /<head>/, res.body
      assert_equal %w[External/www.google.com/Net::HTTP/GET External/allOther External/www.google.com/all].sort,
      metrics_without_gc.sort
    end

    def test_background
      perform_action_with_newrelic_trace("task", :category => :task) do
        url = URI.parse('http://www.google.com/index.html')
        res = Net::HTTP.start(url.host, url.port) {|http|
          http.get('/index.html')
        }
        assert_match /<head>/, res.body
      end
      assert_equal %w[External/www.google.com/Net::HTTP/GET External/allOther External/www.google.com/all
       External/www.google.com/Net::HTTP/GET:OtherTransaction/Background/NewRelic::Agent::Instrumentation::NetInstrumentationTest/task].sort, metrics_without_gc.select{|m| m =~ /^External/}.sort
    end

    def test_transactional
      perform_action_with_newrelic_trace("task") do
        url = URI.parse('http://www.google.com/index.html')
        res = Net::HTTP.start(url.host, url.port) {|http|
          http.get('/index.html')
        }
        assert_match /<head>/, res.body
      end
      assert_equal %w[External/www.google.com/Net::HTTP/GET External/allWeb External/www.google.com/all
       External/www.google.com/Net::HTTP/GET:Controller/NewRelic::Agent::Instrumentation::NetInstrumentationTest/task].sort, metrics_without_gc.select{|m| m =~ /^External/}.sort
    end
    def test_get__simple
      Net::HTTP.get URI.parse('http://www.google.com/index.html')
      assert_equal metrics_without_gc.sort,
      %w[External/www.google.com/Net::HTTP/GET External/allOther External/www.google.com/all].sort
    end
    def test_ignore
      NewRelic::Agent.disable_all_tracing do
        url = URI.parse('http://www.google.com/index.html')
        res = Net::HTTP.start(url.host, url.port) {|http|
          http.post('/index.html','data')
        }
      end
      assert_equal 0, metrics_without_gc.size
    end
    def test_head
      url = URI.parse('http://www.google.com/index.html')
      res = Net::HTTP.start(url.host, url.port) {|http|
        http.head('/index.html')
      }
      assert_equal %w[External/www.google.com/Net::HTTP/HEAD External/allOther External/www.google.com/all].sort,
      metrics_without_gc.sort
    end

    def test_post
      url = URI.parse('http://www.google.com/index.html')
      res = Net::HTTP.start(url.host, url.port) {|http|
        http.post('/index.html','data')
      }
      assert_equal %w[External/www.google.com/Net::HTTP/POST External/allOther External/www.google.com/all].sort,
      metrics_without_gc.sort
    end

  end
end
