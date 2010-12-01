# $Id: testfilter.rb 245 2007-05-05 02:44:32Z blackhedd $

require 'common'

class TestFilter < Test::Unit::TestCase

	# Note that the RFC doesn't define either less-than or greater-than.
	def test_rfc_2254
		Net::LDAP::Filter.from_rfc2254( " ( uid=george*   ) " )
		Net::LDAP::Filter.from_rfc2254( "uid!=george*" )
		Net::LDAP::Filter.from_rfc2254( "uid <= george*" )
		Net::LDAP::Filter.from_rfc2254( "uid>=george*" )
		Net::LDAP::Filter.from_rfc2254( "uid!=george*" )

		Net::LDAP::Filter.from_rfc2254( "(& (uid!=george* ) (mail=*))" )
		Net::LDAP::Filter.from_rfc2254( "(| (uid!=george* ) (mail=*))" )
		Net::LDAP::Filter.from_rfc2254( "(! (mail=*))" )
	end

	def test_filters_from_ber
		[
			Net::LDAP::Filter.eq( "objectclass", "*" ),
			Net::LDAP::Filter.pres( "objectclass" ),
			Net::LDAP::Filter.eq( "objectclass", "ou" ),
			Net::LDAP::Filter.ge( "uid", "500" ),
			Net::LDAP::Filter.le( "uid", "500" ),
			(~ Net::LDAP::Filter.pres( "objectclass" )),
			(Net::LDAP::Filter.pres( "objectclass" ) & Net::LDAP::Filter.pres( "ou" )),
			(Net::LDAP::Filter.pres( "objectclass" ) & Net::LDAP::Filter.pres( "ou" ) & Net::LDAP::Filter.pres("sn")),
			(Net::LDAP::Filter.pres( "objectclass" ) | Net::LDAP::Filter.pres( "ou" ) | Net::LDAP::Filter.pres("sn")),

			Net::LDAP::Filter.eq( "objectclass", "*aaa" ),
			Net::LDAP::Filter.eq( "objectclass", "*aaa*bbb" ),
			Net::LDAP::Filter.eq( "objectclass", "*aaa*bbb*ccc" ),
			Net::LDAP::Filter.eq( "objectclass", "aaa*bbb" ),
			Net::LDAP::Filter.eq( "objectclass", "aaa*bbb*ccc" ),
			Net::LDAP::Filter.eq( "objectclass", "abc*def*1111*22*g" ),
			Net::LDAP::Filter.eq( "objectclass", "*aaa*" ),
			Net::LDAP::Filter.eq( "objectclass", "*aaa*bbb*" ),
			Net::LDAP::Filter.eq( "objectclass", "*aaa*bbb*ccc*" ),
			Net::LDAP::Filter.eq( "objectclass", "aaa*" ),
			Net::LDAP::Filter.eq( "objectclass", "aaa*bbb*" ),
			Net::LDAP::Filter.eq( "objectclass", "aaa*bbb*ccc*" ),
		].each {|ber|
			f = Net::LDAP::Filter.parse_ber( ber.to_ber.read_ber( Net::LDAP::AsnSyntax) )
			assert( f == ber )
			assert_equal( f.to_ber, ber.to_ber )
		}

	end

	def test_ber_from_rfc2254_filter
		[
			Net::LDAP::Filter.construct( "objectclass=*" ),
			Net::LDAP::Filter.construct("objectclass=ou" ),
			Net::LDAP::Filter.construct("uid >= 500" ),
			Net::LDAP::Filter.construct("uid <= 500" ),
			Net::LDAP::Filter.construct("(!(uid=*))" ),
			Net::LDAP::Filter.construct("(&(uid=*)(objectclass=*))" ),
			Net::LDAP::Filter.construct("(&(uid=*)(objectclass=*)(sn=*))" ),
			Net::LDAP::Filter.construct("(|(uid=*)(objectclass=*))" ),
			Net::LDAP::Filter.construct("(|(uid=*)(objectclass=*)(sn=*))" ),

			Net::LDAP::Filter.construct("objectclass=*aaa"),
			Net::LDAP::Filter.construct("objectclass=*aaa*bbb"),
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
		].each {|ber|
		f = Net::LDAP::Filter.parse_ber( ber.to_ber.read_ber( Net::LDAP::AsnSyntax) )
			assert( f == ber )
			assert_equal( f.to_ber, ber.to_ber )
		}
	end

end
