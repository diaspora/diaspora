require 'common'

class ResponseTest < Net::SFTP::TestCase
  def test_code_should_default_to_FX_OK
    response = Net::SFTP::Response.new(mock("response"))
    assert_equal Net::SFTP::Response::FX_OK, response.code
  end

  def test_brackets_should_symbolize_key
    response = Net::SFTP::Response.new(mock("response"), :handle => "foo")
    assert_equal "foo", response['handle']
  end

  def test_to_s_with_nil_message_should_show_default_message
    response = Net::SFTP::Response.new(mock("response"), :code => 14)
    assert_equal "no space on filesystem (14)", response.to_s
  end

  def test_to_s_with_empty_message_should_show_default_message
    response = Net::SFTP::Response.new(mock("response"), :code => 14, :message => "")
    assert_equal "no space on filesystem (14)", response.to_s
  end

  def test_to_s_with_default_message_should_show_default_message
    response = Net::SFTP::Response.new(mock("response"), :code => 14, :message => "no space on filesystem")
    assert_equal "no space on filesystem (14)", response.to_s
  end

  def test_to_s_with_explicit_message_should_show_explicit_message
    response = Net::SFTP::Response.new(mock("response"), :code => 14, :message => "out of space")
    assert_equal "out of space (no space on filesystem, 14)", response.to_s
  end

  def test_ok_should_be_true_when_code_is_FX_OK
    response = Net::SFTP::Response.new(mock("response"))
    assert_equal true, response.ok?
  end

  def test_ok_should_be_false_when_code_is_not_FX_OK
    response = Net::SFTP::Response.new(mock("response"), :code => 14)
    assert_equal false, response.ok?
  end

  def test_eof_should_be_true_when_code_is_FX_EOF
    response = Net::SFTP::Response.new(mock("response"), :code => 1)
    assert_equal true, response.eof?
  end

  def test_eof_should_be_false_when_code_is_not_FX_EOF
    response = Net::SFTP::Response.new(mock("response"), :code => 14)
    assert_equal false, response.eof?
  end
end
