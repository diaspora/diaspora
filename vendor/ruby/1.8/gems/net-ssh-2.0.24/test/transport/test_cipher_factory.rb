require 'common'
require 'net/ssh/transport/cipher_factory'

module Transport

  class TestCipherFactory < Test::Unit::TestCase
    def self.if_supported?(name)
      yield if Net::SSH::Transport::CipherFactory.supported?(name)
    end

    def test_lengths_for_none
      assert_equal [0,0], factory.get_lengths("none")
      assert_equal [0,0], factory.get_lengths("bogus")
    end

    def test_lengths_for_blowfish_cbc
      assert_equal [16,8], factory.get_lengths("blowfish-cbc")
    end

    if_supported?("idea-cbc") do
      def test_lengths_for_idea_cbc
        assert_equal [16,8], factory.get_lengths("idea-cbc")
      end
    end

    def test_lengths_for_rijndael_cbc
      assert_equal [32,16], factory.get_lengths("rijndael-cbc@lysator.liu.se")
    end

    def test_lengths_for_cast128_cbc
      assert_equal [16,8], factory.get_lengths("cast128-cbc")
    end

    def test_lengths_for_3des_cbc
      assert_equal [24,8], factory.get_lengths("3des-cbc")
    end

    def test_lengths_for_aes192_cbc
      assert_equal [24,16], factory.get_lengths("aes192-cbc")
    end

    def test_lengths_for_aes128_cbc
      assert_equal [16,16], factory.get_lengths("aes128-cbc")
    end

    def test_lengths_for_aes256_cbc
      assert_equal [32,16], factory.get_lengths("aes256-cbc")
    end

    def test_lengths_for_arcfour128
      assert_equal [16,8], factory.get_lengths("arcfour128")
    end
    
    def test_lengths_for_arcfour256
      assert_equal [32,8], factory.get_lengths("arcfour256")
    end
    
    def test_lengths_for_arcfour512
      assert_equal [64,8], factory.get_lengths("arcfour512")
    end
    
    BLOWFISH = "\210\021\200\315\240_\026$\352\204g\233\244\242x\332e\370\001\327\224Nv@9_\323\037\252kb\037\036\237\375]\343/y\037\237\312Q\f7]\347Y\005\275%\377\0010$G\272\250B\265Nd\375\342\372\025r6}+Y\213y\n\237\267\\\374^\346BdJ$\353\220Ik\023<\236&H\277=\225"

    def test_blowfish_cbc_for_encryption
      assert_equal BLOWFISH, encrypt("blowfish-cbc")
    end

    def test_blowfish_cbc_for_decryption
      assert_equal TEXT, decrypt("blowfish-cbc", BLOWFISH)
    end

    if_supported?("idea-cbc") do
      IDEA = "W\234\017G\231\b\357\370H\b\256U]\343M\031k\233]~\023C\363\263\177\262-\261\341$\022\376mv\217\322\b\2763\270H\306\035\343z\313\312\3531\351\t\201\302U\022\360\300\354ul7$z\320O]\360g\024\305\005`V\005\335A\351\312\270c\320D\232\eQH1\340\265\2118\031g*\303v"

      def test_idea_cbc_for_encryption
        assert_equal IDEA, encrypt("idea-cbc")
      end

      def test_idea_cbc_for_decryption
        assert_equal TEXT, decrypt("idea-cbc", IDEA)
      end
    end

    RIJNDAEL = "$\253\271\255\005Z\354\336&\312\324\221\233\307Mj\315\360\310Fk\241EfN\037\231\213\361{'\310\204\347I\343\271\005\240`\325;\034\346uM>#\241\231C`\374\261\vo\226;Z\302:\b\250\366T\330\\#V\330\340\226\363\374!\bm\266\232\207!\232\347\340\t\307\370\356z\236\343=v\210\206y"

    def test_rijndael_cbc_for_encryption
      assert_equal RIJNDAEL, encrypt("rijndael-cbc@lysator.liu.se")
    end

    def test_rijndael_cbc_for_decryption
      assert_equal TEXT, decrypt("rijndael-cbc@lysator.liu.se", RIJNDAEL)
    end

    CAST128 = "qW\302\331\333P\223t[9 ~(sg\322\271\227\272\022I\223\373p\255>k\326\314\260\2003\236C_W\211\227\373\205>\351\334\322\227\223\e\236\202Ii\032!P\214\035:\017\360h7D\371v\210\264\317\236a\262w1\2772\023\036\331\227\240:\f/X\351\324I\t[x\350\323E\2301\016m"

    def test_cast128_cbc_for_encryption
      assert_equal CAST128, encrypt("cast128-cbc")
    end

    def test_cast128_cbc_for_decryption
      assert_equal TEXT, decrypt("cast128-cbc", CAST128)
    end

    TRIPLE_DES = "\322\252\216D\303Q\375gg\367A{\177\313\3436\272\353%\223K?\257\206|\r&\353/%\340\336 \203E8rY\206\234\004\274\267\031\233T/{\"\227/B!i?[qGaw\306T\206\223\213n \212\032\244%]@\355\250\334\312\265E\251\017\361\270\357\230\274KP&^\031r+r%\370"

    def test_3des_cbc_for_encryption
      assert_equal TRIPLE_DES, encrypt("3des-cbc")
    end

    def test_3des_cbc_for_decryption
      assert_equal TEXT, decrypt("3des-cbc", TRIPLE_DES)
    end

    AES128 = "k\026\350B\366-k\224\313\3277}B\035\004\200\035\r\233\024$\205\261\231Q\2214r\245\250\360\315\237\266hg\262C&+\321\346Pf\267v\376I\215P\327\345-\232&HK\375\326_\030<\a\276\212\303g\342C\242O\233\260\006\001a&V\345`\\T\e\236.\207\223l\233ri^\v\252\363\245"

    def test_aes128_cbc_for_encryption
      assert_equal AES128, encrypt("aes128-cbc")
    end

    def test_aes128_cbc_for_decryption
      assert_equal TEXT, decrypt("aes128-cbc", AES128)
    end

    AES192 = "\256\017)x\270\213\336\303L\003f\235'jQ\3231k9\225\267\242\364C4\370\224\201\302~\217I\202\374\2167='\272\037\225\223\177Y\r\212\376(\275\n\3553\377\177\252C\254\236\016MA\274Z@H\331<\rL\317\205\323[\305X8\376\237=\374\352bH9\244\0231\353\204\352p\226\326~J\242"

    def test_aes192_cbc_for_encryption
      assert_equal AES192, encrypt("aes192-cbc")
    end

    def test_aes192_cbc_for_decryption
      assert_equal TEXT, decrypt("aes192-cbc", AES192)
    end

    AES256 = "$\253\271\255\005Z\354\336&\312\324\221\233\307Mj\315\360\310Fk\241EfN\037\231\213\361{'\310\204\347I\343\271\005\240`\325;\034\346uM>#\241\231C`\374\261\vo\226;Z\302:\b\250\366T\330\\#V\330\340\226\363\374!\bm\266\232\207!\232\347\340\t\307\370\356z\236\343=v\210\206y"

    def test_aes256_cbc_for_encryption
      assert_equal AES256, encrypt("aes256-cbc")
    end

    def test_aes256_cbc_for_decryption
      assert_equal TEXT, decrypt("aes256-cbc", AES256)
    end
    
    ARCFOUR128 = "\n\x90\xED*\xD4\xBE\xCBg5\xA5\a\xEC]\x97\xB7L\x06)6\x12FL\x90@\xF4Sqxqh\r\x11\x1Aq \xC8\xE6v\xC6\x12\xD9<A\xDAZ\xFE\x7F\x88\x19f.\x06\xA7\xFE:\xFF\x93\x9B\x8D\xA0\\\x9E\xCA\x03\x15\xE1\xE2\f\xC0\b\xA2C\xE1\xBD\xB6\x13D\xD1\xB4'g\x89\xDC\xEB\f\x19Z)U"

    def test_arcfour128_for_encryption
      assert_equal ARCFOUR128, encrypt("arcfour128")
    end
    
    def test_arcfour128_for_decryption
      assert_equal TEXT, decrypt("arcfour128", ARCFOUR128)
    end
    
    ARCFOUR256 = "|g\xCCw\xF5\xC1y\xEB\xF0\v\xF7\x83\x14\x03\xC8\xAB\xE8\xC2\xFCY\xDC,\xB8\xD4dVa\x8B\x18%\xA4S\x00\xE0at\x86\xE8\xA6W\xAB\xD2\x9D\xA8\xDE[g\aZy.\xFB\xFC\x82c\x04h\f\xBFYq\xB7U\x80\x0EG\x91\x88\xDF\xA3\xA2\xFA(\xEC\xDB\xA4\xE7\xFE)\x12u\xAF\x0EZ\xA0\xBA\x97\n\xFC"

    def test_arcfour256_for_encryption
      assert_equal ARCFOUR256, encrypt("arcfour256")
    end
    
    def test_arcfour256_for_decryption
      assert_equal TEXT, decrypt("arcfour256", ARCFOUR256)
    end
    
    ARCFOUR512 = "|8\"v\xE7\xE3\b\xA8\x19\x9Aa\xB6Vv\x00\x11\x8A$C\xB6xE\xEF\xF1j\x90\xA8\xFA\x10\xE4\xA1b8\xF6\x04\xF2+\xC0\xD1(8\xEBT]\xB0\xF3/\xD9\xE0@\x83\a\x93\x9D\xCA\x04RXS\xB7A\x0Fj\x94\bE\xEB\x84j\xB4\xDF\nU\xF7\x83o\n\xE8\xF9\x01{jH\xEE\xCDQym\x9E"

    def test_arcfour512_for_encryption
      assert_equal ARCFOUR512, encrypt("arcfour512")
    end
    
    def test_arcfour512_for_decryption
      assert_equal TEXT, decrypt("arcfour512", ARCFOUR512)
    end
    
    def test_none_for_encryption
      assert_equal TEXT, encrypt("none").strip
    end

    def test_none_for_decryption
      assert_equal TEXT, decrypt("none", TEXT)
    end
    
    private

      TEXT = "But soft! What light through yonder window breaks? It is the east, and Juliet is the sun!"

      OPTIONS = { :iv => "ABC",
        :key => "abc",
        :digester => OpenSSL::Digest::MD5,
        :shared => "1234567890123456780",
        :hash => '!@#$%#$^%$&^&%#$@$'
      }

      def factory
        Net::SSH::Transport::CipherFactory
      end

      def encrypt(type)
        cipher = factory.get(type, OPTIONS.merge(:encrypt => true))
        padding = TEXT.length % cipher.block_size
        result = cipher.update(TEXT.dup)
        result << cipher.update(" " * (cipher.block_size - padding)) if padding > 0
        result << cipher.final
      end

      def decrypt(type, data)
        cipher = factory.get(type, OPTIONS.merge(:decrypt => true))
        result = cipher.update(data.dup)
        result << cipher.final
        result.strip
      end
  end

end
