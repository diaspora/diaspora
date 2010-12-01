# $Id$
$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'test/unit'
require 'net/ntlm'

class FunctionTest < Test::Unit::TestCase #:nodoc:
	def setup
		@passwd = "SecREt01"
		@user   = "user"
		@domain = "domain"
		@challenge = ["0123456789abcdef"].pack("H*")
		@client_ch = ["ffffff0011223344"].pack("H*")
		@timestamp = 1055844000
	   @trgt_info = [
	   	"02000c0044004f004d00410049004e00" + 
	   	"01000c00530045005200560045005200" +
	   	"0400140064006f006d00610069006e00" +
	   	"2e0063006f006d000300220073006500" +
	   	"72007600650072002e0064006f006d00" +
	   	"610069006e002e0063006f006d000000" +
	   	"0000"
	   ].pack("H*")
	end

	def test_lm_hash
		ahash = ["ff3750bcc2b22412c2265b23734e0dac"].pack("H*")
		assert_equal ahash, Net::NTLM::lm_hash(@passwd)
	end

	def test_ntlm_hash
		ahash = ["cd06ca7c7e10c99b1d33b7485a2ed808"].pack("H*")
		assert_equal ahash, Net::NTLM::ntlm_hash(@passwd)
	end

	def test_ntlmv2_hash
		ahash = ["04b8e0ba74289cc540826bab1dee63ae"].pack("H*")
		assert_equal ahash, Net::NTLM::ntlmv2_hash(@user, @passwd, @domain)
	end
	
	def test_lm_response
		ares = ["c337cd5cbd44fc9782a667af6d427c6de67c20c2d3e77c56"].pack("H*")
		assert_equal ares, Net::NTLM::lm_response(
			{
				:lm_hash => Net::NTLM::lm_hash(@passwd),
				:challenge => @challenge
			}
		)
	end
	
	def test_ntlm_response
		ares = ["25a98c1c31e81847466b29b2df4680f39958fb8c213a9cc6"].pack("H*")
		ntlm_hash = Net::NTLM::ntlm_hash(@passwd)
		assert_equal ares, Net::NTLM::ntlm_response(
			{
				:ntlm_hash => ntlm_hash,
				:challenge => @challenge
			}
		)
	end

	def test_lmv2_response
		ares = ["d6e6152ea25d03b7c6ba6629c2d6aaf0ffffff0011223344"].pack("H*")
		assert_equal ares, Net::NTLM::lmv2_response(
			{
				:ntlmv2_hash => Net::NTLM::ntlmv2_hash(@user, @passwd, @domain),
				:challenge => @challenge
			},
			{ :client_challenge => @client_ch }
		)
	end
	
	def test_ntlmv2_response
		ares = [
			"cbabbca713eb795d04c97abc01ee4983" +
  			"01010000000000000090d336b734c301" +
  			"ffffff00112233440000000002000c00" +
			"44004f004d00410049004e0001000c00" +
  			"53004500520056004500520004001400" +
  			"64006f006d00610069006e002e006300" +
  			"6f006d00030022007300650072007600" +
  			"650072002e0064006f006d0061006900" +
  			"6e002e0063006f006d00000000000000" +
  			"0000"
  		].pack("H*")
		assert_equal ares, Net::NTLM::ntlmv2_response(
			{
				:ntlmv2_hash => Net::NTLM::ntlmv2_hash(@user, @passwd, @domain),
				:challenge => @challenge,
				:target_info => @trgt_info
			},
			{
				:timestamp => @timestamp,
				:client_challenge => @client_ch
			}
		)
	end
	
	def test_ntlm2_session
		acha = ["ffffff001122334400000000000000000000000000000000"].pack("H*")
  		ares = ["10d550832d12b2ccb79d5ad1f4eed3df82aca4c3681dd455"].pack("H*")
		session = Net::NTLM::ntlm2_session(
			{
				:ntlm_hash => Net::NTLM::ntlm_hash(@passwd),
		 		:challenge => @challenge
		 	},
			{ :client_challenge => @client_ch }
		)
		assert_equal acha, session[0]
		assert_equal ares, session[1]
	end
end
