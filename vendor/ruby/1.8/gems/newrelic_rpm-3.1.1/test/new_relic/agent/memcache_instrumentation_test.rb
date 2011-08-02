require File.expand_path(File.join(File.dirname(__FILE__),'..','..','test_helper'))

memcached_ready = false
classes = {
#   'memcache' => 'MemCache'
#   'dalli' => 'Dalli::Client'
#   'memcached' => 'Memcached'
  'spymemcached' => 'Spymemcached'
}
begin
  TCPSocket.new('localhost', 11211)
  classes.each do |req, const|
    begin
      require req
      MEMCACHED_CLASS = const.constantize
      puts "Testing #{MEMCACHED_CLASS}"
      memcached_ready = true
    rescue LoadError
    rescue NameError
    end
  end
rescue Errno::ECONNREFUSED
rescue Errno::ETIMEDOUT
end

class NewRelic::Agent::MemcacheInstrumentationTest < Test::Unit::TestCase
  include NewRelic::Agent::Instrumentation::ControllerInstrumentation

  def setup
    NewRelic::Agent.manual_start
    @engine = NewRelic::Agent.instance.stats_engine
    
    case MEMCACHED_CLASS.name
    when 'Memcached'
      @cache = MEMCACHED_CLASS.new('localhost', :support_cas => true)
    when 'Spymemcached'
      @cache = MEMCACHED_CLASS.new('localhost:11211')
    else
      @cache = MEMCACHED_CLASS.new('localhost')
    end
    @key = 'schluessel'
    @cache.set('schluessel', 1)
  end
  
  def teardown
    if MEMCACHED_CLASS.name == 'Memecached'
      @cache.flush
    elsif MEMCACHED_CLASS.name == 'Spymemcached'
      @cache.flush
      @cache.instance_eval{ @client.shutdown }
    else
      @cache.flush_all
    end
  end
  
  def _call_test_method_in_web_transaction(method, *args)
    @engine.clear_stats
    perform_action_with_newrelic_trace(:name=>'action', :category => :controller) do
      @cache.send(method.to_sym, *[@key, *args])
    end
  end

  def _call_test_method_in_background_task(method, *args)
    @engine.clear_stats
    perform_action_with_newrelic_trace(:name => 'bg_task', :category => :task) do
      @cache.send(method.to_sym, *[@key, *args])
    end
  end

  def test_reads__web
    commands = ['get']
    commands << 'get_multi' unless MEMCACHED_CLASS.name == 'Spymemcached'
    commands.each do |method|
      if @cache.class.method_defined?(method)
        _call_test_method_in_web_transaction(method)
        compare_metrics ["MemCache/#{method}", "MemCache/allWeb", "MemCache/#{method}:Controller/NewRelic::Agent::MemcacheInstrumentationTest/action"],
        @engine.metrics.select{|m| m =~ /^memcache.*/i}
      end
    end
  end

  def test_writes__web
    %w[delete].each do |method|
      if @cache.class.method_defined?(method)
        _call_test_method_in_web_transaction(method)
        expected_metrics = ["MemCache/#{method}", "MemCache/allWeb", "MemCache/#{method}:Controller/NewRelic::Agent::MemcacheInstrumentationTest/action"]
        compare_metrics expected_metrics, @engine.metrics.select{|m| m =~ /^memcache.*/i}
      end
    end

    %w[set add].each do |method|
      @cache.delete(@key) rescue nil
      if @cache.class.method_defined?(method)
        expected_metrics = ["MemCache/#{method}", "MemCache/allWeb", "MemCache/#{method}:Controller/NewRelic::Agent::MemcacheInstrumentationTest/action"]
        _call_test_method_in_web_transaction(method, 'value')
        compare_metrics expected_metrics, @engine.metrics.select{|m| m =~ /^memcache.*/i}
      end
    end
  end

  def test_reads__background
    commands = ['get']
    commands << 'get_multi' unless MEMCACHED_CLASS.name == 'Spymemcached'
    commands.each do |method|    
      if @cache.class.method_defined?(method)
        _call_test_method_in_background_task(method)
        compare_metrics ["MemCache/#{method}", "MemCache/allOther", "MemCache/#{method}:OtherTransaction/Background/NewRelic::Agent::MemcacheInstrumentationTest/bg_task"],
        @engine.metrics.select{|m| m =~ /^memcache.*/i}
      end
    end
  end

  def test_writes__background
    %w[delete].each do |method|
      expected_metrics = ["MemCache/#{method}", "MemCache/allOther", "MemCache/#{method}:OtherTransaction/Background/NewRelic::Agent::MemcacheInstrumentationTest/bg_task"]
      if @cache.class.method_defined?(method)
        _call_test_method_in_background_task(method)
        compare_metrics expected_metrics, @engine.metrics.select{|m| m =~ /^memcache.*/i}
      end
    end

    %w[set add].each do |method|
      @cache.delete(@key) rescue nil
      expected_metrics = ["MemCache/#{method}", "MemCache/allOther", "MemCache/#{method}:OtherTransaction/Background/NewRelic::Agent::MemcacheInstrumentationTest/bg_task"]
      if @cache.class.method_defined?(method)
        _call_test_method_in_background_task(method, 'value')
        compare_metrics expected_metrics, @engine.metrics.select{|m| m =~ /^memcache.*/i}
      end
    end
  end

  def test_handles_cas
    expected_metrics = ["MemCache/cas", "MemCache/allOther", "MemCache/cas:OtherTransaction/Background/NewRelic::Agent::MemcacheInstrumentationTest/bg_task"]
    if @cache.class.method_defined?(:cas)
      @engine.clear_stats
      perform_action_with_newrelic_trace(:name => 'bg_task', :category => :task) do
        @cache.cas(@key) {|val| val += 2 }
      end
      compare_metrics expected_metrics, @engine.metrics.select{|m| m =~ /^memcache.*/i}
      assert_equal 3, @cache.get(@key)
    end    
  end

end if memcached_ready
