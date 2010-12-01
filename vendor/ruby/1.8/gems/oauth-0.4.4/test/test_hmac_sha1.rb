require File.expand_path('../test_helper', __FILE__)

class TestSignatureHmacSha1 < Test::Unit::TestCase
  def test_that_hmac_sha1_implements_hmac_sha1
    assert OAuth::Signature.available_methods.include?('hmac-sha1')
  end

  def test_that_get_request_from_oauth_test_cases_produces_matching_signature
    request = Net::HTTP::Get.new('/photos?file=vacation.jpg&size=original&oauth_version=1.0&oauth_consumer_key=dpf43f3p2l4k3l03&oauth_token=nnch734d00sl2jdk&oauth_timestamp=1191242096&oauth_nonce=kllo9940pd9333jh&oauth_signature_method=HMAC-SHA1')

    consumer = OAuth::Consumer.new('dpf43f3p2l4k3l03', 'kd94hf93k423kf44')
    token = OAuth::Token.new('nnch734d00sl2jdk', 'pfkkdhi9sl3r4s00')

    signature = OAuth::Signature.sign(request, { :consumer => consumer,
                                                 :token => token,
                                                 :uri => 'http://photos.example.net/photos' } )

    assert_equal 'tR3+Ty81lMeYAr/Fid0kMTYa/WM=', signature
  end
end
