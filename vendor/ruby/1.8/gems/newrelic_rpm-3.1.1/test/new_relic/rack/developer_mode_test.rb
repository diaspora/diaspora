# ENV['SKIP_RAILS'] = 'true'
require File.expand_path(File.join(File.dirname(__FILE__),'..', '..',
                                   'test_helper'))
require 'rack/test'
require 'new_relic/rack/developer_mode'

ENV['RACK_ENV'] = 'test'

class DeveloperModeTest < Test::Unit::TestCase
  include Rack::Test::Methods
  include TransactionSampleTestHelper

  def app
    mock_app = lambda { |env| [500, {}, "Don't touch me!"] }
    NewRelic::Rack::DeveloperMode.new(mock_app)
  end
  
  def setup
    @sampler = NewRelic::Agent::TransactionSampler.new
    run_sample_trace_on(@sampler, '/here')
    run_sample_trace_on(@sampler, '/there')
    run_sample_trace_on(@sampler, '/somewhere')
    NewRelic::Agent.instance.stubs(:transaction_sampler).returns(@sampler)
  end
  
  def test_index_displays_all_samples
    get '/newrelic'
    
    assert last_response.ok?
    assert last_response.body.include?('/here')
    assert last_response.body.include?('/there')
    assert last_response.body.include?('/somewhere')    
  end

  def test_show_sample_summary_displays_sample_details
    get "/newrelic/show_sample_summary?id=#{@sampler.samples[0].sample_id}"
    
    assert last_response.ok?
    assert last_response.body.include?('/here')
    assert last_response.body.include?('SandwichesController')
    assert last_response.body.include?('index')    
  end  
end
