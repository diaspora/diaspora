require File.expand_path('../test_helper', __FILE__)
require 'oauth/signature/plaintext'

class TestSignaturePlaintext < Test::Unit::TestCase
  def test_that_plaintext_implements_plaintext
    assert OAuth::Signature.available_methods.include?('plaintext')
  end

  def test_that_get_request_from_oauth_test_cases_produces_matching_signature
    request = Net::HTTP::Get.new('/photos?file=vacation.jpg&size=original&oauth_version=1.0&oauth_consumer_key=dpf43f3p2l4k3l03&oauth_token=nnch734d00sl2jdk&oauth_signature=kd94hf93k423kf44%26&oauth_timestamp=1191242096&oauth_nonce=kllo9940pd9333jh&oauth_signature_method=PLAINTEXT')

    consumer = OAuth::Consumer.new('dpf43f3p2l4k3l03','kd94hf93k423kf44')
    token = OAuth::Token.new('nnch734d00sl2jdk', nil)

    assert OAuth::Signature.verify(request, { :consumer => consumer,
                                                :token => token,
                                                :uri => 'http://photos.example.net/photos' } )
  end

  def test_that_get_request_from_oauth_test_cases_produces_matching_signature_part_two
    request = Net::HTTP::Get.new('/photos?file=vacation.jpg&size=original&oauth_version=1.0&oauth_consumer_key=dpf43f3p2l4k3l03&oauth_token=nnch734d00sl2jdk&oauth_signature=kd94hf93k423kf44%26pfkkdhi9sl3r4s00&oauth_timestamp=1191242096&oauth_nonce=kllo9940pd9333jh&oauth_signature_method=PLAINTEXT')

    consumer = OAuth::Consumer.new('dpf43f3p2l4k3l03','kd94hf93k423kf44')
    token = OAuth::Token.new('nnch734d00sl2jdk', 'pfkkdhi9sl3r4s00')

    assert OAuth::Signature.verify(request, { :consumer => consumer,
                                                :token => token,
                                                :uri => 'http://photos.example.net/photos' } )
  end

end
