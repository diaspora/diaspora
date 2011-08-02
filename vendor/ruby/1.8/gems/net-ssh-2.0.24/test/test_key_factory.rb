require 'common'
require 'net/ssh/key_factory'

class TestKeyFactory < Test::Unit::TestCase
  def test_load_unencrypted_private_RSA_key_should_return_key
    File.expects(:read).with("/key-file").returns(rsa_key.export)
    assert_equal rsa_key.to_der, Net::SSH::KeyFactory.load_private_key("/key-file").to_der
  end

  def test_load_unencrypted_private_DSA_key_should_return_key
    File.expects(:read).with("/key-file").returns(dsa_key.export)
    assert_equal dsa_key.to_der, Net::SSH::KeyFactory.load_private_key("/key-file").to_der
  end

  def test_load_encrypted_private_RSA_key_should_prompt_for_password_and_return_key
    File.expects(:read).with("/key-file").returns(encrypted(rsa_key, "password"))
    Net::SSH::KeyFactory.expects(:prompt).with("Enter passphrase for /key-file:", false).returns("password")
    assert_equal rsa_key.to_der, Net::SSH::KeyFactory.load_private_key("/key-file").to_der
  end

  def test_load_encrypted_private_RSA_key_with_password_should_not_prompt_and_return_key
    File.expects(:read).with("/key-file").returns(encrypted(rsa_key, "password"))
    assert_equal rsa_key.to_der, Net::SSH::KeyFactory.load_private_key("/key-file", "password").to_der
  end

  def test_load_encrypted_private_DSA_key_should_prompt_for_password_and_return_key
    File.expects(:read).with("/key-file").returns(encrypted(dsa_key, "password"))
    Net::SSH::KeyFactory.expects(:prompt).with("Enter passphrase for /key-file:", false).returns("password")
    assert_equal dsa_key.to_der, Net::SSH::KeyFactory.load_private_key("/key-file").to_der
  end

  def test_load_encrypted_private_DSA_key_with_password_should_not_prompt_and_return_key
    File.expects(:read).with("/key-file").returns(encrypted(dsa_key, "password"))
    assert_equal dsa_key.to_der, Net::SSH::KeyFactory.load_private_key("/key-file", "password").to_der
  end

  def test_load_encrypted_private_key_should_give_three_tries_for_the_password_and_then_raise_exception
    File.expects(:read).with("/key-file").returns(encrypted(rsa_key, "password"))
    Net::SSH::KeyFactory.expects(:prompt).times(3).with("Enter passphrase for /key-file:", false).returns("passwod","passphrase","passwd")
    assert_raises(OpenSSL::PKey::RSAError) { Net::SSH::KeyFactory.load_private_key("/key-file") }
  end

  def test_load_public_rsa_key_should_return_key
    File.expects(:read).with("/key-file").returns(public(rsa_key))
    assert_equal rsa_key.to_blob, Net::SSH::KeyFactory.load_public_key("/key-file").to_blob
  end

  private

    def rsa_key
      # 512 bits
      @rsa_key ||= OpenSSL::PKey::RSA.new("0\202\001;\002\001\000\002A\000\235\236\374N\e@2E\321\3757\003\354c\276N\f\003\3479Ko\005\317\0027\a\255=\345!\306\220\340\211;\027u\331\260\362\2063x\332\301y4\353\v%\032\214v\312\304\212\271GJ\353\2701\031\002\003\001\000\001\002@\022Y\306*\031\306\031\224Cde\231QV3{\306\256U\2477\377\017\000\020\323\363R\332\027\351\034\224OU\020\227H|pUS\n\263+%\304\341\321\273/\271\e\004L\250\273\020&,\t\304By\002!\000\311c\246%a\002\305\277\262R\266\244\250\025V_\351]\264\016\265\341\355\305\223\347Z$8\205#\023\002!\000\310\\\367|\243I\363\350\020\307\246\302\365\ed\212L\273\2158M\223w\a\367 C\t\224A4\243\002!\000\262]+}\327\231\331\002\2331^\312\036\204'g\363\f&\271\020\245\365-\024}\306\374e\202\2459\002 }\231\341\276\3551\277\307{5\\\361\233\353G\024wS\237\fk}\004\302&\205\277\340rb\211\327\002!\000\223\307\025I:\215_\260\370\252\3757\256Y&X\364\354\342\215\350\203E8\227|\f\237M\375D|")
    end

    def dsa_key
      # 512 bits
      @dsa_key ||= OpenSSL::PKey::DSA.new("0\201\367\002\001\000\002A\000\203\316/\037u\272&J\265\003l3\315d\324h\372{\t8\252#\331_\026\006\035\270\266\255\343\353Z\302\276\335\336\306\220\375\202L\244\244J\206>\346\b\315\211\302L\246x\247u\a\376\366\345\302\016#\002\025\000\244\274\302\221Og\275/\302+\356\346\360\024\373wI\2573\361\002@\027\215\270r*\f\213\350C\245\021:\350 \006\\\376\345\022`\210b\262\3643\023XLKS\320\370\002\276\347A\nU\204\276\324\256`=\026\240\330\306J\316V\213\024\e\030\215\355\006\037q\337\356ln\002@\017\257\034\f\260\333'S\271#\237\230E\321\312\027\021\226\331\251Vj\220\305\316\036\v\266+\000\230\270\177B\003?t\a\305]e\344\261\334\023\253\323\251\223M\2175)a(\004\"lI8\312\303\307\a\002\024_\aznW\345\343\203V\326\246ua\203\376\201o\350\302\002")
    end

    def encrypted(key, password)
      key.export(OpenSSL::Cipher::Cipher.new("des-ede3-cbc"), password)
    end

    def public(key)
      result = "#{key.ssh_type} "
      result << [Net::SSH::Buffer.from(:key, key).to_s].pack("m*").strip.tr("\n\r\t ", "")
      result << " joe@host.test"
    end
end