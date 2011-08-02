require File.expand_path(File.join(File.dirname(__FILE__),'..', '..',
                                   'test_helper'))
require 'rack/test'
require 'new_relic/rack/browser_monitoring'

ENV['RACK_ENV'] = 'test'

class BrowserMonitoringTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    @doc ||= <<-EOL
<html>
  <head>
    <title>im a title</title>
    <meta some-crap="1"/>
    <script>
      junk
    </script>
  </head>
  <body>im some body text</body>
</html>
EOL
    mock_app = lambda do |env|
      [200, {'Content-Type' => 'text/html'}, Rack::Response.new(@doc)]
    end
    NewRelic::Rack::BrowserMonitoring.new(mock_app)
  end

  def setup
    NewRelic::Agent.stubs(:browser_timing_header) \
      .returns("<script>header</script>")
    NewRelic::Agent.stubs(:browser_timing_footer) \
      .returns("<script>footer</script>")
  end
  
  def teardown
    mocha_teardown
  end
  
  def test_should_only_instrument_successfull_html_requests
    assert app.should_instrument?(200, {'Content-Type' => 'text/html'})
    assert !app.should_instrument?(500, {'Content-Type' => 'text/html'})
    assert !app.should_instrument?(200, {'Content-Type' => 'text/xhtml'})
  end

  def test_insert_timing_header_right_after_open_head_if_no_meta_tags
    get '/'
    
    assert(last_response.body.include?("head>#{NewRelic::Agent.browser_timing_header}"), last_response.body)
    @doc = nil
  end  
  
  def test_insert_timing_header_right_before_head_close_if_ua_compatible_found
    @doc = <<-EOL
<html>
  <head>
    <title>im a title</title>
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1"/>
    <script>
      junk
    </script>
  </head>
  <body>im some body text</body>
</html>
EOL
    get '/'
    
    assert(last_response.body.include?("#{NewRelic::Agent.browser_timing_header}</head>"), last_response.body)
  end
  
  def test_insert_timing_footer_right_before_html_body_close
    get '/'
    
    assert(last_response.body.include?("#{NewRelic::Agent.browser_timing_footer}</body>"), last_response.body)
  end

  def test_should_not_throw_exception_on_empty_reponse
    @doc = ''
    get '/'

    assert last_response.ok?
  end
end
