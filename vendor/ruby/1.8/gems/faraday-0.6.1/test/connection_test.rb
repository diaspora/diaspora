require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))

class TestConnection < Faraday::TestCase
  def test_initialize_parses_host_out_of_given_url
    conn = Faraday::Connection.new "http://sushi.com"
    assert_equal 'sushi.com', conn.host
  end

  def test_initialize_parses_nil_port_out_of_given_url
    conn = Faraday::Connection.new "http://sushi.com"
    assert_nil conn.port
  end

  def test_initialize_parses_scheme_out_of_given_url
    conn = Faraday::Connection.new "http://sushi.com"
    assert_equal 'http', conn.scheme
  end

  def test_initialize_parses_port_out_of_given_url
    conn = Faraday::Connection.new "http://sushi.com:815"
    assert_equal 815, conn.port
  end

  def test_initialize_parses_nil_path_prefix_out_of_given_url
    conn = Faraday::Connection.new "http://sushi.com"
    assert_equal '/', conn.path_prefix
  end

  def test_initialize_parses_path_prefix_out_of_given_url
    conn = Faraday::Connection.new "http://sushi.com/fish"
    assert_equal '/fish', conn.path_prefix
  end

  def test_initialize_parses_path_prefix_out_of_given_url_option
    conn = Faraday::Connection.new :url => "http://sushi.com/fish"
    assert_equal '/fish', conn.path_prefix
  end

  def test_initialize_stores_default_params_from_options
    conn = Faraday::Connection.new :params => {:a => 1}
    assert_equal 1, conn.params['a']
  end

  def test_initialize_stores_default_params_from_uri
    conn = Faraday::Connection.new "http://sushi.com/fish?a=1", :params => {'b' => '2'}
    assert_equal '1', conn.params['a']
    assert_equal '2', conn.params['b']
  end

  def test_initialize_stores_default_headers_from_options
    conn = Faraday::Connection.new :headers => {:a => 1}
    assert_equal '1', conn.headers['A']
  end

  def test_basic_auth_sets_authorization_header
    conn = Faraday::Connection.new
    conn.basic_auth 'Aladdin', 'open sesame'
    assert_equal 'Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ==', conn.headers['Authorization']
  end

  def test_long_basic_auth_sets_authorization_header_without_new_lines
    conn = Faraday::Connection.new
    conn.basic_auth "A" * 255, ""
    assert_equal "Basic #{'QUFB' * 85}Og==", conn.headers['Authorization']
  end

  def test_auto_parses_basic_auth_from_url
    conn = Faraday::Connection.new :url => "http://aladdin:opensesame@sushi.com/fish"
    assert_equal 'Basic YWxhZGRpbjpvcGVuc2VzYW1l', conn.headers['Authorization']
  end

  def test_token_auth_sets_authorization_header
    conn = Faraday::Connection.new
    conn.token_auth 'abcdef'
    assert_equal 'Token token="abcdef"', conn.headers['Authorization']
  end

  def test_token_auth_with_options_sets_authorization_header
    conn = Faraday::Connection.new
    conn.token_auth 'abcdef', :nonce => 'abc'
    assert_equal 'Token token="abcdef",
                     nonce="abc"', conn.headers['Authorization']
  end

  def test_build_url_uses_connection_host_as_default_uri_host
    conn = Faraday::Connection.new
    conn.host = 'sushi.com'
    uri = conn.build_url("/sake.html")
    assert_equal 'sushi.com', uri.host
  end

  def test_build_url_uses_connection_port_as_default_uri_port
    conn = Faraday::Connection.new
    conn.port = 23
    uri = conn.build_url("http://sushi.com")
    assert_equal 23, uri.port
  end

  def test_build_url_uses_connection_scheme_as_default_uri_scheme
    conn = Faraday::Connection.new 'http://sushi.com'
    uri = conn.build_url("/sake.html")
    assert_equal 'http', uri.scheme
  end

  def test_build_url_uses_connection_path_prefix_to_customize_path
    conn = Faraday::Connection.new
    conn.path_prefix = '/fish'
    uri = conn.build_url("sake.html")
    assert_equal '/fish/sake.html', uri.path
  end

  def test_build_url_uses_root_connection_path_prefix_to_customize_path
    conn = Faraday::Connection.new
    conn.path_prefix = '/'
    uri = conn.build_url("sake.html")
    assert_equal '/sake.html', uri.path
  end

  def test_build_url_forces_connection_path_prefix_to_be_absolute
    conn = Faraday::Connection.new
    conn.path_prefix = 'fish'
    uri = conn.build_url("sake.html")
    assert_equal '/fish/sake.html', uri.path
  end

  def test_build_url_ignores_connection_path_prefix_trailing_slash
    conn = Faraday::Connection.new
    conn.path_prefix = '/fish/'
    uri = conn.build_url("sake.html")
    assert_equal '/fish/sake.html', uri.path
  end

  def test_build_url_allows_absolute_uri_to_ignore_connection_path_prefix
    conn = Faraday::Connection.new
    conn.path_prefix = '/fish'
    uri = conn.build_url("/sake.html")
    assert_equal '/sake.html', uri.path
  end

  def test_build_url_parses_url_params_into_path
    conn = Faraday::Connection.new
    uri = conn.build_url("http://sushi.com/sake.html")
    assert_equal '/sake.html', uri.path
  end

  def test_build_url_parses_url_params_into_query
    conn = Faraday::Connection.new
    uri = conn.build_url("http://sushi.com/sake.html", 'a[b]' => '1 + 2')
    assert_equal "a%5Bb%5D=1%20%2B%202", uri.query
  end

  def test_build_url_mashes_default_and_given_params_together
    conn = Faraday::Connection.new 'http://sushi.com/api?token=abc', :params => {'format' => 'json'}
    url = conn.build_url("nigiri?page=1", :limit => 5)
    assert_match /limit=5/,      url.query
    assert_match /page=1/,       url.query
    assert_match /format=json/,  url.query
    assert_match /token=abc/,    url.query
  end

  def test_build_url_overrides_default_params_with_given_params
    conn = Faraday::Connection.new 'http://sushi.com/api?token=abc', :params => {'format' => 'json'}
    url = conn.build_url("nigiri?page=1", :limit => 5, :token => 'def', :format => 'xml')
    assert_match /limit=5/,        url.query
    assert_match /page=1/,         url.query
    assert_match /format=xml/,     url.query
    assert_match /token=def/,      url.query
    assert_no_match /format=json/, url.query
    assert_no_match /token=abc/,   url.query
  end

  def test_build_url_parses_url
    conn = Faraday::Connection.new
    uri = conn.build_url("http://sushi.com/sake.html")
    assert_equal "http",             uri.scheme
    assert_equal "sushi.com",        uri.host
    assert_equal '/sake.html', uri.path
    assert_nil uri.port
  end

  def test_build_url_parses_url_and_changes_scheme
    conn = Faraday::Connection.new :url => "http://sushi.com/sushi"
    conn.scheme = 'https'
    uri = conn.build_url("sake.html")
    assert_equal 'https://sushi.com/sushi/sake.html', uri.to_s
  end

  def test_proxy_accepts_string
    conn = Faraday::Connection.new
    conn.proxy 'http://proxy.com'
    assert_equal 'proxy.com', conn.proxy[:uri].host
    assert_equal [:uri],      conn.proxy.keys
  end

  def test_proxy_accepts_uri
    conn = Faraday::Connection.new
    conn.proxy Addressable::URI.parse('http://proxy.com')
    assert_equal 'proxy.com', conn.proxy[:uri].host
    assert_equal [:uri],      conn.proxy.keys
  end

  def test_proxy_accepts_hash_with_string_uri
    conn = Faraday::Connection.new
    conn.proxy :uri => 'http://proxy.com', :user => 'rick'
    assert_equal 'proxy.com', conn.proxy[:uri].host
    assert_equal 'rick',      conn.proxy[:user]
  end

  def test_proxy_accepts_hash
    conn = Faraday::Connection.new
    conn.proxy :uri => Addressable::URI.parse('http://proxy.com'), :user => 'rick'
    assert_equal 'proxy.com', conn.proxy[:uri].host
    assert_equal 'rick',      conn.proxy[:user]
  end

  def test_proxy_requires_uri
    conn = Faraday::Connection.new
    assert_raises ArgumentError do
      conn.proxy :uri => :bad_uri, :user => 'rick'
    end
  end

  def test_params_to_query_converts_hash_of_params_to_uri_escaped_query_string
    conn = Faraday::Connection.new
    class << conn
      public :build_query
    end
    assert_equal "a%5Bb%5D=1%20%2B%202", conn.build_query('a[b]' => '1 + 2')
  end

  def test_dups_connection_object
    conn = Faraday::Connection.new 'http://sushi.com/foo' do |b|
      b.adapter :net_http
    end
    conn.headers['content-type'] = 'text/plain'
    conn.params['a'] = '1'

    duped = conn.dup
    assert_equal conn.build_url(''), duped.build_url('')
    [:headers, :params, :builder].each do |attr|
      assert_equal     conn.send(attr),           duped.send(attr)
      assert_not_equal conn.send(attr).object_id, duped.send(attr).object_id
    end
  end
end
