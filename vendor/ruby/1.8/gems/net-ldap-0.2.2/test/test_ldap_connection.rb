require 'common'

class TestLDAP < Test::Unit::TestCase
  def test_modify_ops_delete
    args = { :operations => [ [ :delete, "mail" ] ] }
    result = Net::LDAP::Connection.modify_ops(args[:operations])
    expected = [ "0\r\n\x01\x010\b\x04\x04mail1\x00" ]
    assert_equal(expected, result)
  end

  def test_modify_ops_add
    args = { :operations => [ [ :add, "mail", "testuser@example.com" ] ] }
    result = Net::LDAP::Connection.modify_ops(args[:operations])
    expected = [ "0#\n\x01\x000\x1E\x04\x04mail1\x16\x04\x14testuser@example.com" ]
    assert_equal(expected, result)
  end

  def test_modify_ops_replace
    args = { :operations =>[ [ :replace, "mail", "testuser@example.com" ] ] }
    result = Net::LDAP::Connection.modify_ops(args[:operations])
    expected = [ "0#\n\x01\x020\x1E\x04\x04mail1\x16\x04\x14testuser@example.com" ]
    assert_equal(expected, result)
  end
end
