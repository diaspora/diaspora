require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'test_helper'))
class NewRelic::Agent::Instrumentation::InstrumentationTest < Test::Unit::TestCase
  def test_load_all_instrumentation_files
    # just checking for syntax errors and unguarded code
    Dir.glob(NEWRELIC_PLUGIN_DIR + '/lib/new_relic/agent/instrumentation/**/*.rb') do |f|
      require f
    end
    require 'new_relic/delayed_job_injection'
  end
end

