require File.expand_path(File.join(File.dirname(__FILE__),'..','..','..','test_helper'))
class NewRelic::Agent::Instrumentation::ActiveRecordInstrumentationTest < Test::Unit::TestCase
  require 'active_record_fixtures'
  include NewRelic::Agent::Instrumentation::ControllerInstrumentation

  @@setup = false
  def setup
    super
    unless @@setup
      NewRelic::Agent.manual_start
      @setup = true
    end
    ActiveRecordFixtures.setup
    NewRelic::Agent.instance.transaction_sampler.reset!
    NewRelic::Agent.instance.stats_engine.clear_stats
  rescue Exception => e
    puts e
    puts e.backtrace.join("\n")
  end

  def teardown
    super
    NewRelic::Agent.shutdown
  end

  #####################################################################
  # Note: If these tests are failing, most likely the problem is that #
  # the active record instrumentation is not loading for whichever    #
  # version of rails you're testing at the moment.                    #
  #####################################################################

  def test_agent_setup
    assert NewRelic::Agent.instance.class == NewRelic::Agent::Agent
  end

  def test_finder
    ActiveRecordFixtures::Order.create :id => 0, :name => 'jeff'

    find_metric = "ActiveRecord/ActiveRecordFixtures::Order/find"

    assert_calls_metrics(find_metric) do
      ActiveRecordFixtures::Order.find(:all)
      check_metric_count(find_metric, 1)
      ActiveRecordFixtures::Order.find_all_by_name "jeff"
      check_metric_count(find_metric, 2)
    end

    return if NewRelic::Control.instance.rails_version < "2.3.4" ||
      NewRelic::Control.instance.rails_version >= "3.1"

    assert_calls_metrics(find_metric) do
      ActiveRecordFixtures::Order.exists?(["name=?", 'jeff'])
    end
    check_metric_count(find_metric, 3)
  end

  # multiple duplicate find calls should only cause metric trigger on the first
  # call.  the others are ignored.
  def test_query_cache
    # Not sure why we get a transaction error with sqlite
    return if isSqlite?

    find_metric = "ActiveRecord/ActiveRecordFixtures::Order/find"
    ActiveRecordFixtures::Order.cache do
      m = ActiveRecordFixtures::Order.create :id => 0, :name => 'jeff'
      assert_calls_metrics(find_metric) do
        ActiveRecordFixtures::Order.find(:all)
      end

      check_metric_count(find_metric, 1)

      assert_calls_metrics(find_metric) do
        10.times { ActiveRecordFixtures::Order.find m.id }
      end
      check_metric_count(find_metric, 2)
    end
  end

  def test_metric_names_jruby
    # fails due to a bug in rails 3 - log does not provide the correct
    # transaction type - it returns 'SQL' instead of 'Foo Create', for example.
    return if rails3? || !defined?(JRuby)
    expected = %W[
      ActiveRecord/all
      ActiveRecord/find
      ActiveRecord/ActiveRecordFixtures::Order/find
      Database/SQL/insert]

    if NewRelic::Control.instance.rails_version < '2.1.0'
      expected += %W[ActiveRecord/save ActiveRecord/ActiveRecordFixtures::Order/save]
    end

    assert_calls_metrics(*expected) do
      m = ActiveRecordFixtures::Order.create :id => 0, :name => 'jeff'
      m = ActiveRecordFixtures::Order.find(m.id)
      m.id = 999
      m.save!
    end
    metrics = NewRelic::Agent.instance.stats_engine.metrics

    compare_metrics expected, metrics
    check_metric_count("ActiveRecord/ActiveRecordFixtures::Order/find", 1)
    # zero because jruby uses a different mysql adapter
    check_metric_count("ActiveRecord/ActiveRecordFixtures::Order/create", 0)
  end

  def test_metric_names_sqlite
    # fails due to a bug in rails 3 - log does not provide the correct
    # transaction type - it returns 'SQL' instead of 'Foo Create', for example.
    return if rails3? || !isSqlite? || defined?(JRuby)

    expected = %W[
      ActiveRecord/all
      ActiveRecord/find
      ActiveRecord/ActiveRecordFixtures::Order/find
      ActiveRecord/create
      ActiveRecord/ActiveRecordFixtures::Order/create]

    if NewRelic::Control.instance.rails_version < '2.1.0'
      expected += %W[ActiveRecord/save ActiveRecord/ActiveRecordFixtures::Order/save]
    end

    assert_calls_metrics(*expected) do
      m = ActiveRecordFixtures::Order.create :id => 0, :name => 'jeff'
      m = ActiveRecordFixtures::Order.find(m.id)
      m.id = 999
      m.save!
    end
    metrics = NewRelic::Agent.instance.stats_engine.metrics

    compare_metrics expected, metrics
    check_metric_count("ActiveRecord/ActiveRecordFixtures::Order/find", 1)
    check_metric_count("ActiveRecord/ActiveRecordFixtures::Order/create", 1)
  end


  def test_metric_names_standard
    # fails due to a bug in rails 3 - log does not provide the correct
    # transaction type - it returns 'SQL' instead of 'Foo Create', for example.
    return if rails3? || defined?(JRuby) || isSqlite?

    expected = %W[
      ActiveRecord/all
      ActiveRecord/find
      ActiveRecord/ActiveRecordFixtures::Order/find
      ActiveRecord/create
      Database/SQL/other
      ActiveRecord/ActiveRecordFixtures::Order/create]

    if NewRelic::Control.instance.rails_version < '2.1.0'
      expected += %W[ActiveRecord/save ActiveRecord/ActiveRecordFixtures::Order/save]
    end

    assert_calls_metrics(*expected) do
      m = ActiveRecordFixtures::Order.create :id => 0, :name => 'jeff'
      m = ActiveRecordFixtures::Order.find(m.id)
      m.id = 999
      m.save!
    end

    metrics = NewRelic::Agent.instance.stats_engine.metrics

    compare_metrics expected, metrics
    check_metric_count("ActiveRecord/ActiveRecordFixtures::Order/find", 1)
    check_metric_count("ActiveRecord/ActiveRecordFixtures::Order/create", 1)
  end

  def test_join_metrics_jruby
    return unless defined?(JRuby)
    return if rails3?

    expected_metrics = %W[
    ActiveRecord/all
    ActiveRecord/destroy
    ActiveRecord/ActiveRecordFixtures::Order/destroy
    Database/SQL/insert
    Database/SQL/delete
    ActiveRecord/find
    ActiveRecord/ActiveRecordFixtures::Order/find
    ActiveRecord/ActiveRecordFixtures::Shipment/find
    ]

    assert_calls_metrics(*expected_metrics) do
      m = ActiveRecordFixtures::Order.create :name => 'jeff'
      m = ActiveRecordFixtures::Order.find(m.id)
      s = m.shipments.create
      m.shipments.to_a
      m.destroy
    end

    metrics = NewRelic::Agent.instance.stats_engine.metrics

    compare_metrics expected_metrics, metrics

    check_metric_time('ActiveRecord/all', NewRelic::Agent.get_stats("ActiveRecord/all").total_exclusive_time, 0)
    check_metric_count("ActiveRecord/ActiveRecordFixtures::Order/find", 1)
    check_metric_count("ActiveRecord/ActiveRecordFixtures::Shipment/find", 1)
    check_metric_count("Database/SQL/insert", 3)
    check_metric_count("Database/SQL/delete", 1)
  end

  def test_join_metrics_sqlite
    return if (defined?(Rails) && Rails.respond_to?(:version) && Rails.version.to_i == 3)
    return if defined?(JRuby)
    return unless isSqlite?

    expected_metrics = %W[
    ActiveRecord/all
    ActiveRecord/destroy
    ActiveRecord/ActiveRecordFixtures::Order/destroy
    Database/SQL/insert
    Database/SQL/delete
    ActiveRecord/find
    ActiveRecord/ActiveRecordFixtures::Order/find
    ActiveRecord/ActiveRecordFixtures::Shipment/find
    ActiveRecord/create
    ActiveRecord/ActiveRecordFixtures::Shipment/create
    ActiveRecord/ActiveRecordFixtures::Order/create
    ]

    assert_calls_metrics(*expected_metrics) do
      m = ActiveRecordFixtures::Order.create :name => 'jeff'
      m = ActiveRecordFixtures::Order.find(m.id)
      s = m.shipments.create
      m.shipments.to_a
      m.destroy
    end

    metrics = NewRelic::Agent.instance.stats_engine.metrics
    compare_metrics expected_metrics, metrics
    if !(defined?(RUBY_DESCRIPTION) && RUBY_DESCRIPTION =~ /Enterprise Edition/)
      check_metric_time('ActiveRecord/all', NewRelic::Agent.get_stats("ActiveRecord/all").total_exclusive_time, 0)
    end
    check_metric_count("ActiveRecord/ActiveRecordFixtures::Order/find", 1)
    check_metric_count("ActiveRecord/ActiveRecordFixtures::Shipment/find", 1)
    check_metric_count("Database/SQL/insert", 3)
    check_metric_count("Database/SQL/delete", 1)
  end

  def test_join_metrics_standard
    return if (defined?(Rails) && Rails.respond_to?(:version) && Rails.version.to_i == 3)
    return if defined?(JRuby) || isSqlite?

    expected_metrics = %W[
    ActiveRecord/all
    ActiveRecord/destroy
    ActiveRecord/ActiveRecordFixtures::Order/destroy
    Database/SQL/insert
    Database/SQL/delete
    ActiveRecord/find
    ActiveRecord/ActiveRecordFixtures::Order/find
    ActiveRecord/ActiveRecordFixtures::Shipment/find
    Database/SQL/other
    Database/SQL/show
    ActiveRecord/create
    ActiveRecord/ActiveRecordFixtures::Shipment/create
    ActiveRecord/ActiveRecordFixtures::Order/create
    ]

    assert_calls_metrics(*expected_metrics) do
      m = ActiveRecordFixtures::Order.create :name => 'jeff'
      m = ActiveRecordFixtures::Order.find(m.id)
      s = m.shipments.create
      m.shipments.to_a
      m.destroy
    end

    metrics = NewRelic::Agent.instance.stats_engine.metrics

    compare_metrics expected_metrics, metrics
    if !(defined?(RUBY_DESCRIPTION) && RUBY_DESCRIPTION =~ /Enterprise Edition/)
      check_metric_time('ActiveRecord/all', NewRelic::Agent.get_stats("ActiveRecord/all").total_exclusive_time, 0)
    end
    check_metric_count("ActiveRecord/ActiveRecordFixtures::Order/find", 1)
    check_metric_count("ActiveRecord/ActiveRecordFixtures::Shipment/find", 1)
    check_metric_count("Database/SQL/insert", 1)
    check_metric_count("Database/SQL/delete", 1)
  end

  def test_direct_sql
    assert_nil NewRelic::Agent::Instrumentation::MetricFrame.current
    assert_nil NewRelic::Agent.instance.stats_engine.scope_name
    assert_equal 0, NewRelic::Agent.instance.stats_engine.metrics.size, NewRelic::Agent.instance.stats_engine.metrics.inspect

    expected_metrics = %W[
    ActiveRecord/all
    Database/SQL/select
    ]

    assert_calls_unscoped_metrics(*expected_metrics) do
      ActiveRecordFixtures::Order.connection.select_rows "select * from #{ActiveRecordFixtures::Order.table_name}"
    end

    metrics = NewRelic::Agent.instance.stats_engine.metrics
    compare_metrics(expected_metrics, metrics)

    check_unscoped_metric_count('Database/SQL/select', 1)

  end

  def test_other_sql
    expected_metrics = %W[
    ActiveRecord/all
    Database/SQL/other
    ]
    assert_calls_unscoped_metrics(*expected_metrics) do
      ActiveRecordFixtures::Order.connection.execute "begin"
    end

    metrics = NewRelic::Agent.instance.stats_engine.metrics

    compare_metrics expected_metrics, metrics
    check_unscoped_metric_count('Database/SQL/other', 1)
  end

  def test_show_sql
    return if isSqlite?

    expected_metrics = %W[ActiveRecord/all Database/SQL/show]

    assert_calls_metrics(*expected_metrics) do
      ActiveRecordFixtures::Order.connection.execute "show tables"
    end
    metrics = NewRelic::Agent.instance.stats_engine.metrics
    compare_metrics expected_metrics, metrics
    check_unscoped_metric_count('Database/SQL/show', 1)
  end

  def test_blocked_instrumentation
    ActiveRecordFixtures::Order.add_delay
    NewRelic::Agent.disable_all_tracing do
      perform_action_with_newrelic_trace :name => 'bogosity' do
        ActiveRecordFixtures::Order.find(:all)
      end
    end
    assert_nil NewRelic::Agent.instance.transaction_sampler.last_sample
    metrics = NewRelic::Agent.instance.stats_engine.metrics
    compare_metrics [], metrics
  end
  def test_run_explains
    perform_action_with_newrelic_trace :name => 'bogosity' do
      ActiveRecordFixtures::Order.add_delay
      ActiveRecordFixtures::Order.find(:all)
    end

    # that's a mouthful. perhaps we should ponder our API.
    segment = NewRelic::Agent.instance.transaction_sampler.last_sample.root_segment.called_segments.first.called_segments.first.called_segments.first
    regex = /^SELECT (["`]?#{ActiveRecordFixtures::Order.table_name}["`]?.)?\* FROM ["`]?#{ActiveRecordFixtures::Order.table_name}["`]?$/
    assert_match regex, segment.params[:sql].strip
  end
  def test_prepare_to_send
    perform_action_with_newrelic_trace :name => 'bogosity' do
      ActiveRecordFixtures::Order.add_delay
      ActiveRecordFixtures::Order.find(:all)
    end
    sample = NewRelic::Agent.instance.transaction_sampler.last_sample
    assert_not_nil sample

    includes_gc = false
    sample.each_segment {|s| includes_gc ||= s.metric_name =~ /GC/ }

    assert_equal (includes_gc ? 4 : 3), sample.count_segments, sample.to_s

    sql_segment = sample.root_segment.called_segments.first.called_segments.first.called_segments.first
    assert_not_nil sql_segment, sample.to_s
    assert_match /^SELECT /, sql_segment.params[:sql]
    assert sql_segment.duration > 0.0, "Segment duration must be greater than zero."
    sample = sample.prepare_to_send(:record_sql => :raw, :explain_sql => 0.0)
    sql_segment = sample.root_segment.called_segments.first.called_segments.first.called_segments.first
    assert_match /^SELECT /, sql_segment.params[:sql]
    explanations = sql_segment.params[:explanation]
    if isMysql? || isPostgres?
      assert_not_nil explanations, "No explains in segment: #{sql_segment}"
      assert_equal 1, explanations.size,"No explains in segment: #{sql_segment}"
      assert_equal 1, explanations.first.size
    end
  end

  def test_transaction_mysql
    return unless isMysql? && !defined?(JRuby)
    ActiveRecordFixtures.setup
    sample = NewRelic::Agent.instance.transaction_sampler.reset!
    perform_action_with_newrelic_trace :name => 'bogosity' do
      ActiveRecordFixtures::Order.add_delay
      ActiveRecordFixtures::Order.find(:all)
    end

    sample = NewRelic::Agent.instance.transaction_sampler.last_sample

    sample = sample.prepare_to_send(:record_sql => :obfuscated, :explain_sql => 0.0)
    segment = sample.root_segment.called_segments.first.called_segments.first.called_segments.first
    explanations = segment.params[:explanation]
    assert_not_nil explanations, "No explains in segment: #{segment}"
    assert_equal 1, explanations.size,"No explains in segment: #{segment}"
    assert_equal 1, explanations.first.size, "should be one row of explanation"

    row = explanations.first.first
    assert_equal 10, row.size
    assert_equal ['1', 'SIMPLE', ActiveRecordFixtures::Order.table_name], row[0..2]

    s = NewRelic::Agent.get_stats("ActiveRecord/ActiveRecordFixtures::Order/find")
    assert_equal 1, s.call_count
  end

  def test_transaction_postgres
    return unless isPostgres?
    # note that our current test builds do not use postgres, this is
    # here strictly for troubleshooting, not CI builds
    sample = NewRelic::Agent.instance.transaction_sampler.reset!
    perform_action_with_newrelic_trace :name => 'bogosity' do
      ActiveRecordFixtures::Order.add_delay
      ActiveRecordFixtures::Order.find(:all)
    end

    sample = NewRelic::Agent.instance.transaction_sampler.last_sample

    sample = sample.prepare_to_send(:record_sql => :obfuscated, :explain_sql => 0.0)
    segment = sample.root_segment.called_segments.first.called_segments.first.called_segments.first
    explanations = segment.params[:explanation]

    assert_not_nil explanations, "No explains in segment: #{segment}"
    assert_equal 1, explanations.size,"No explains in segment: #{segment}"
    assert_equal 1, explanations.first.size

    assert_equal Array, explanations.class
    assert_equal Array, explanations[0].class
    assert_equal Array, explanations[0][0].class
    assert_match /Seq Scan on test_data/, explanations[0][0].join(";")

    s = NewRelic::Agent.get_stats("ActiveRecord/ActiveRecordFixtures::Order/find")
    assert_equal 1, s.call_count
  end

  def test_transaction_other
    return if isMysql? || isPostgres?
    sample = NewRelic::Agent.instance.transaction_sampler.reset!
    perform_action_with_newrelic_trace :name => 'bogosity' do
      ActiveRecordFixtures::Order.add_delay
      ActiveRecordFixtures::Order.find(:all)
    end

    sample = NewRelic::Agent.instance.transaction_sampler.last_sample

    sample = sample.prepare_to_send(:record_sql => :obfuscated, :explain_sql => 0.0)
    segment = sample.root_segment.called_segments.first.called_segments.first.called_segments.first

    s = NewRelic::Agent.get_stats("ActiveRecord/ActiveRecordFixtures::Order/find")
    assert_equal 1, s.call_count
  end

  # These are only valid for rails 2.1 and later
  if NewRelic::Control.instance.rails_version >= NewRelic::VersionNumber.new("2.1.0")
    ActiveRecordFixtures::Order.class_eval do
      if NewRelic::Control.instance.rails_version < NewRelic::VersionNumber.new("3.1")
        named_scope :jeffs, :conditions => { :name => 'Jeff' }
      else
        scope :jeffs, :conditions => { :name => 'Jeff' }
      end      
    end
    def test_named_scope
      ActiveRecordFixtures::Order.create :name => 'Jeff'

      find_metric = "ActiveRecord/ActiveRecordFixtures::Order/find"

      check_metric_count(find_metric, 0)
      assert_calls_metrics(find_metric) do
        x = ActiveRecordFixtures::Order.jeffs.find(:all)
      end
      check_metric_count(find_metric, 1)
    end
  end

  # This is to make sure the all metric is recorded for exceptional cases
  def test_error_handling
    # have the AR select throw an error
    ActiveRecordFixtures::Order.connection.stubs(:log_info).with do | sql, x, y |
      raise "Error" if sql =~ /select/
      true
    end

    expected_metrics = %W[ActiveRecord/all Database/SQL/select]

    assert_calls_metrics(*expected_metrics) do
      begin
        ActiveRecordFixtures::Order.connection.select_rows "select * from #{ActiveRecordFixtures::Order.table_name}"
      rescue RuntimeError => e
        # catch only the error we raise above
        raise unless e.message == 'Error'
      end
    end
    metrics = NewRelic::Agent.instance.stats_engine.metrics
    compare_metrics expected_metrics, metrics
    check_metric_count('Database/SQL/select', 1)
    check_metric_count('ActiveRecord/all', 1)
  end

  def test_rescue_handling
    # Not sure why we get a transaction error with sqlite
    return if isSqlite?

    begin
      ActiveRecordFixtures::Order.transaction do
        raise ActiveRecord::ActiveRecordError.new('preserve-me!')
      end
    rescue ActiveRecord::ActiveRecordError => e
      assert_equal 'preserve-me!', e.message
    end
  end

  private

  def rails3?
    (defined?(Rails) && Rails.respond_to?(:version) && Rails.version.to_i == 3)
  end

  def rails_env
    rails3? ? ::Rails.env : RAILS_ENV
  end

  def isPostgres?
    ActiveRecordFixtures::Order.configurations[rails_env]['adapter'] =~ /postgres/i
  end
  def isMysql?
    ActiveRecordFixtures::Order.connection.class.name =~ /mysql/i
  end

  def isSqlite?
    ActiveRecord::Base.configurations[rails_env]['adapter'] =~ /sqlite/i
  end

end
