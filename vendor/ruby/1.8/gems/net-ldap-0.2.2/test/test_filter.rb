require 'common'

class TestFilter < Test::Unit::TestCase
  Filter = Net::LDAP::Filter

  def test_bug_7534_rfc2254
    assert_equal("(cn=Tim Wizard)",
                 Filter.from_rfc2254("(cn=Tim Wizard)").to_rfc2254)
  end

  def test_invalid_filter_string
    assert_raises(Net::LDAP::LdapError) { Filter.from_rfc2254("") }
  end

  def test_invalid_filter
    assert_raises(Net::LDAP::LdapError) {
      # This test exists to prove that our constructor blocks unknown filter
      # types. All filters must be constructed using helpers.
      Filter.__send__(:new, :xx, nil, nil)
    }
  end

  def test_to_s
    assert_equal("(uid=george *)", Filter.eq("uid", "george *").to_s)
  end

  def test_convenience_filters
    assert_equal("(uid=\\2A)", Filter.equals("uid", "*").to_s)
    assert_equal("(uid=\\28*)", Filter.begins("uid", "(").to_s)
    assert_equal("(uid=*\\29)", Filter.ends("uid", ")").to_s)
    assert_equal("(uid=*\\5C*)", Filter.contains("uid", "\\").to_s)	
  end

	def test_c2
    assert_equal("(uid=george *)",
                 Filter.from_rfc2254("uid=george *").to_rfc2254)
    assert_equal("(uid:=george *)",
                 Filter.from_rfc2254("uid:=george *").to_rfc2254)
    assert_equal("(uid=george*)",
                 Filter.from_rfc2254(" ( uid =  george*   ) ").to_rfc2254)
		assert_equal("(!(uid=george*))",
                 Filter.from_rfc2254("uid!=george*").to_rfc2254)
		assert_equal("(uid<=george*)",
                 Filter.from_rfc2254("uid <= george*").to_rfc2254)
		assert_equal("(uid>=george*)",
                 Filter.from_rfc2254("uid>=george*").to_rfc2254)
		assert_equal("(&(uid=george*)(mail=*))",
                 Filter.from_rfc2254("(& (uid=george* ) (mail=*))").to_rfc2254)
		assert_equal("(|(uid=george*)(mail=*))",
                 Filter.from_rfc2254("(| (uid=george* ) (mail=*))").to_rfc2254)
		assert_equal("(!(mail=*))",
                 Filter.from_rfc2254("(! (mail=*))").to_rfc2254)
	end

	def test_filter_with_single_clause
		assert_equal("(cn=name)", Net::LDAP::Filter.construct("(&(cn=name))").to_s)
    end

	def test_filters_from_ber
		[
			Net::LDAP::Filter.eq("objectclass", "*"),
			Net::LDAP::Filter.pres("objectclass"),
			Net::LDAP::Filter.eq("objectclass", "ou"),
			Net::LDAP::Filter.ge("uid", "500"),
			Net::LDAP::Filter.le("uid", "500"),
			(~ Net::LDAP::Filter.pres("objectclass")),
			(Net::LDAP::Filter.pres("objectclass") & Net::LDAP::Filter.pres("ou")),
			(Net::LDAP::Filter.pres("objectclass") & Net::LDAP::Filter.pres("ou") & Net::LDAP::Filter.pres("sn")),
			(Net::LDAP::Filter.pres("objectclass") | Net::LDAP::Filter.pres("ou") | Net::LDAP::Filter.pres("sn")),

			Net::LDAP::Filter.eq("objectclass", "*aaa"),
			Net::LDAP::Filter.eq("objectclass", "*aaa*bbb"),
			Net::LDAP::Filter.eq("objectclass", "*aaa*bbb*ccc"),
			Net::LDAP::Filter.eq("objectclass", "aaa*bbb"),
			Net::LDAP::Filter.eq("objectclass", "aaa*bbb*ccc"),
			Net::LDAP::Filter.eq("objectclass", "abc*def*1111*22*g"),
			Net::LDAP::Filter.eq("objectclass", "*aaa*"),
			Net::LDAP::Filter.eq("objectclass", "*aaa*bbb*"),
			Net::LDAP::Filter.eq("objectclass", "*aaa*bbb*ccc*"),
			Net::LDAP::Filter.eq("objectclass", "aaa*"),
			Net::LDAP::Filter.eq("objectclass", "aaa*bbb*"),
			Net::LDAP::Filter.eq("objectclass", "aaa*bbb*ccc*"),
		].each do |ber|
			f = Net::LDAP::Filter.parse_ber(ber.to_ber.read_ber(Net::LDAP::AsnSyntax))
			assert(f == ber)
			assert_equal(f.to_ber, ber.to_ber)
		end
	end

	def test_ber_from_rfc2254_filter
		[
			Net::LDAP::Filter.construct("objectclass=*"),
			Net::LDAP::Filter.construct("objectclass=ou"),
			Net::LDAP::Filter.construct("uid >= 500"),
			Net::LDAP::Filter.construct("uid <= 500"),
			Net::LDAP::Filter.construct("(!(uid=*))"),
			Net::LDAP::Filter.construct("(&(uid=*)(objectclass=*))"),
			Net::LDAP::Filter.construct("(&(uid=*)(objectclass=*)(sn=*))"),
			Net::LDAP::Filter.construct("(|(uid=*)(objectclass=*))"),
			Net::LDAP::Filter.construct("(|(uid=*)(objectclass=*)(sn=*))"),

			Net::LDAP::Filter.construct("objectclass=*aaa"),
			Net::LDAP::Filter.construct("objectclass=*aaa*bbb"),
			Net::LDAP::Filter.construct("objectclass=*aaa bbb"),
			Net::LDAP::Filter.construct("objectclass=*aaa  bbb"),
			Net::LDAP::Filter.construct("objectclass=*aaa*bbb*ccc"),
			Net::LDAP::Filter.construct("objectclass=aaa*bbb"),
			Net::LDAP::Filter.construct("objectclass=aaa*bbb*ccc"),
			Net::LDAP::Filter.construct("objectclass=abc*def*1111*22*g"),
			Net::LDAP::Filter.construct("objectclass=*aaa*"),
			Net::LDAP::Filter.construct("objectclass=*aaa*bbb*"),
			Net::LDAP::Filter.construct("objectclass=*aaa*bbb*ccc*"),
			Net::LDAP::Filter.construct("objectclass=aaa*"),
			Net::LDAP::Filter.construct("objectclass=aaa*bbb*"),
			Net::LDAP::Filter.construct("objectclass=aaa*bbb*ccc*"),
		].each do |ber|
			f = Net::LDAP::Filter.parse_ber(ber.to_ber.read_ber(Net::LDAP::AsnSyntax))
			assert(f == ber)
			assert_equal(f.to_ber, ber.to_ber)
		end
	end
end
