module Mysql2
  class Client
    attr_reader :query_options
    @@default_query_options = {
      :as => :hash,                   # the type of object you want each row back as; also supports :array (an array of values)
      :async => false,                # don't wait for a result after sending the query, you'll have to monitor the socket yourself then eventually call Mysql2::Client#async_result
      :cast_booleans => false,        # cast tinyint(1) fields as true/false in ruby
      :symbolize_keys => false,       # return field names as symbols instead of strings
      :database_timezone => :local,   # timezone Mysql2 will assume datetime objects are stored in
      :application_timezone => nil,   # timezone Mysql2 will convert to before handing the object back to the caller
      :cache_rows => true,            # tells Mysql2 to use it's internal row cache for results
      :connect_flags => REMEMBER_OPTIONS | LONG_PASSWORD | LONG_FLAG | TRANSACTIONS | PROTOCOL_41 | SECURE_CONNECTION
    }

    def initialize(opts = {})
      @query_options = @@default_query_options.dup

      init_connection

      [:reconnect, :connect_timeout].each do |key|
        next unless opts.key?(key)
        send(:"#{key}=", opts[key])
      end
      # force the encoding to utf8
      self.charset_name = opts[:encoding] || 'utf8'

      ssl_set(*opts.values_at(:sslkey, :sslcert, :sslca, :sslcapath, :sslciper))

      user     = opts[:username]
      pass     = opts[:password]
      host     = opts[:host] || 'localhost'
      port     = opts[:port] || 3306
      database = opts[:database]
      socket   = opts[:socket]
      flags    = opts[:flags] ? opts[:flags] | @query_options[:connect_flags] : @query_options[:connect_flags]

      connect user, pass, host, port, database, socket, flags
    end

    def self.default_query_options
      @@default_query_options
    end

    # NOTE: from ruby-mysql
    if defined? Encoding
      CHARSET_MAP = {
        "armscii8" => nil,
        "ascii"    => Encoding::US_ASCII,
        "big5"     => Encoding::Big5,
        "binary"   => Encoding::ASCII_8BIT,
        "cp1250"   => Encoding::Windows_1250,
        "cp1251"   => Encoding::Windows_1251,
        "cp1256"   => Encoding::Windows_1256,
        "cp1257"   => Encoding::Windows_1257,
        "cp850"    => Encoding::CP850,
        "cp852"    => Encoding::CP852,
        "cp866"    => Encoding::IBM866,
        "cp932"    => Encoding::Windows_31J,
        "dec8"     => nil,
        "eucjpms"  => Encoding::EucJP_ms,
        "euckr"    => Encoding::EUC_KR,
        "gb2312"   => Encoding::EUC_CN,
        "gbk"      => Encoding::GBK,
        "geostd8"  => nil,
        "greek"    => Encoding::ISO_8859_7,
        "hebrew"   => Encoding::ISO_8859_8,
        "hp8"      => nil,
        "keybcs2"  => nil,
        "koi8r"    => Encoding::KOI8_R,
        "koi8u"    => Encoding::KOI8_U,
        "latin1"   => Encoding::ISO_8859_1,
        "latin2"   => Encoding::ISO_8859_2,
        "latin5"   => Encoding::ISO_8859_9,
        "latin7"   => Encoding::ISO_8859_13,
        "macce"    => Encoding::MacCentEuro,
        "macroman" => Encoding::MacRoman,
        "sjis"     => Encoding::SHIFT_JIS,
        "swe7"     => nil,
        "tis620"   => Encoding::TIS_620,
        "ucs2"     => Encoding::UTF_16BE,
        "ujis"     => Encoding::EucJP_ms,
        "utf8"     => Encoding::UTF_8,
      }

      MYSQL_CHARSET_MAP = {
        1 => {:name => "big5",      :collation => "big5_chinese_ci"},
        2 => {:name => "latin2",    :collation => "latin2_czech_cs"},
        3 => {:name => "dec8",      :collation => "dec8_swedish_ci"},
        4 => {:name => "cp850",     :collation => "cp850_general_ci"},
        5 => {:name => "latin1",    :collation => "latin1_german1_ci"},
        6 => {:name => "hp8",       :collation => "hp8_english_ci"},
        7 => {:name => "koi8r",     :collation => "koi8r_general_ci"},
        8 => {:name => "latin1",    :collation => "latin1_swedish_ci"},
        9 => {:name => "latin2",    :collation => "latin2_general_ci"},
        10 => {:name => "swe7",     :collation => "swe7_swedish_ci"},
        11 => {:name => "ascii",    :collation => "ascii_general_ci"},
        12 => {:name => "ujis",     :collation => "ujis_japanese_ci"},
        13 => {:name => "sjis",     :collation => "sjis_japanese_ci"},
        14 => {:name => "cp1251",   :collation => "cp1251_bulgarian_ci"},
        15 => {:name => "latin1",   :collation => "latin1_danish_ci"},
        16 => {:name => "hebrew",   :collation => "hebrew_general_ci"},
        17 => {:name => "filename", :collation => "filename"},
        18 => {:name => "tis620",   :collation => "tis620_thai_ci"},
        19 => {:name => "euckr",    :collation => "euckr_korean_ci"},
        20 => {:name => "latin7",   :collation => "latin7_estonian_cs"},
        21 => {:name => "latin2",   :collation => "latin2_hungarian_ci"},
        22 => {:name => "koi8u",    :collation => "koi8u_general_ci"},
        23 => {:name => "cp1251",   :collation => "cp1251_ukrainian_ci"},
        24 => {:name => "gb2312",   :collation => "gb2312_chinese_ci"},
        25 => {:name => "greek",    :collation => "greek_general_ci"},
        26 => {:name => "cp1250",   :collation => "cp1250_general_ci"},
        27 => {:name => "latin2",   :collation => "latin2_croatian_ci"},
        28 => {:name => "gbk",      :collation => "gbk_chinese_ci"},
        29 => {:name => "cp1257",   :collation => "cp1257_lithuanian_ci"},
        30 => {:name => "latin5",   :collation => "latin5_turkish_ci"},
        31 => {:name => "latin1",   :collation => "latin1_german2_ci"},
        32 => {:name => "armscii8", :collation => "armscii8_general_ci"},
        33 => {:name => "utf8",     :collation => "utf8_general_ci"},
        34 => {:name => "cp1250",   :collation => "cp1250_czech_cs"},
        35 => {:name => "ucs2",     :collation => "ucs2_general_ci"},
        36 => {:name => "cp866",    :collation => "cp866_general_ci"},
        37 => {:name => "keybcs2",  :collation => "keybcs2_general_ci"},
        38 => {:name => "macce",    :collation => "macce_general_ci"},
        39 => {:name => "macroman", :collation => "macroman_general_ci"},
        40 => {:name => "cp852",    :collation => "cp852_general_ci"},
        41 => {:name => "latin7",   :collation => "latin7_general_ci"},
        42 => {:name => "latin7",   :collation => "latin7_general_cs"},
        43 => {:name => "macce",    :collation => "macce_bin"},
        44 => {:name => "cp1250",   :collation => "cp1250_croatian_ci"},
        47 => {:name => "latin1",   :collation => "latin1_bin"},
        48 => {:name => "latin1",   :collation => "latin1_general_ci"},
        49 => {:name => "latin1",   :collation => "latin1_general_cs"},
        50 => {:name => "cp1251",   :collation => "cp1251_bin"},
        51 => {:name => "cp1251",   :collation => "cp1251_general_ci"},
        52 => {:name => "cp1251",   :collation => "cp1251_general_cs"},
        53 => {:name => "macroman", :collation => "macroman_bin"},
        57 => {:name => "cp1256",   :collation => "cp1256_general_ci"},
        58 => {:name => "cp1257",   :collation => "cp1257_bin"},
        59 => {:name => "cp1257",   :collation => "cp1257_general_ci"},
        63 => {:name => "binary",   :collation => "binary"},
        64 => {:name => "armscii8", :collation => "armscii8_bin"},
        65 => {:name => "ascii",    :collation => "ascii_bin"},
        66 => {:name => "cp1250",   :collation => "cp1250_bin"},
        67 => {:name => "cp1256",   :collation => "cp1256_bin"},
        68 => {:name => "cp866",    :collation => "cp866_bin"},
        69 => {:name => "dec8",     :collation => "dec8_bin"},
        70 => {:name => "greek",    :collation => "greek_bin"},
        71 => {:name => "hebrew",   :collation => "hebrew_bin"},
        72 => {:name => "hp8",      :collation => "hp8_bin"},
        73 => {:name => "keybcs2",  :collation => "keybcs2_bin"},
        74 => {:name => "koi8r",    :collation => "koi8r_bin"},
        75 => {:name => "koi8u",    :collation => "koi8u_bin"},
        77 => {:name => "latin2",   :collation => "latin2_bin"},
        78 => {:name => "latin5",   :collation => "latin5_bin"},
        79 => {:name => "latin7",   :collation => "latin7_bin"},
        80 => {:name => "cp850",    :collation => "cp850_bin"},
        81 => {:name => "cp852",    :collation => "cp852_bin"},
        82 => {:name => "swe7",     :collation => "swe7_bin"},
        83 => {:name => "utf8",     :collation => "utf8_bin"},
        84 => {:name => "big5",     :collation => "big5_bin"},
        85 => {:name => "euckr",    :collation => "euckr_bin"},
        86 => {:name => "gb2312",   :collation => "gb2312_bin"},
        87 => {:name => "gbk",      :collation => "gbk_bin"},
        88 => {:name => "sjis",     :collation => "sjis_bin"},
        89 => {:name => "tis620",   :collation => "tis620_bin"},
        90 => {:name => "ucs2",     :collation => "ucs2_bin"},
        91 => {:name => "ujis",     :collation => "ujis_bin"},
        92 => {:name => "geostd8",  :collation => "geostd8_general_ci"},
        93 => {:name => "geostd8",  :collation => "geostd8_bin"},
        94 => {:name => "latin1",   :collation => "latin1_spanish_ci"},
        95 => {:name => "cp932",    :collation => "cp932_japanese_ci"},
        96 => {:name => "cp932",    :collation => "cp932_bin"},
        97 => {:name => "eucjpms",  :collation => "eucjpms_japanese_ci"},
        98 => {:name => "eucjpms",  :collation => "eucjpms_bin"},
        99 => {:name => "cp1250",   :collation => "cp1250_polish_ci"},
        128 => {:name => "ucs2",    :collation => "ucs2_unicode_ci"},
        129 => {:name => "ucs2",    :collation => "ucs2_icelandic_ci"},
        130 => {:name => "ucs2",    :collation => "ucs2_latvian_ci"},
        131 => {:name => "ucs2",    :collation => "ucs2_romanian_ci"},
        132 => {:name => "ucs2",    :collation => "ucs2_slovenian_ci"},
        133 => {:name => "ucs2",    :collation => "ucs2_polish_ci"},
        134 => {:name => "ucs2",    :collation => "ucs2_estonian_ci"},
        135 => {:name => "ucs2",    :collation => "ucs2_spanish_ci"},
        136 => {:name => "ucs2",    :collation => "ucs2_swedish_ci"},
        137 => {:name => "ucs2",    :collation => "ucs2_turkish_ci"},
        138 => {:name => "ucs2",    :collation => "ucs2_czech_ci"},
        139 => {:name => "ucs2",    :collation => "ucs2_danish_ci"},
        140 => {:name => "ucs2",    :collation => "ucs2_lithuanian_ci"},
        141 => {:name => "ucs2",    :collation => "ucs2_slovak_ci"},
        142 => {:name => "ucs2",    :collation => "ucs2_spanish2_ci"},
        143 => {:name => "ucs2",    :collation => "ucs2_roman_ci"},
        144 => {:name => "ucs2",    :collation => "ucs2_persian_ci"},
        145 => {:name => "ucs2",    :collation => "ucs2_esperanto_ci"},
        146 => {:name => "ucs2",    :collation => "ucs2_hungarian_ci"},
        192 => {:name => "utf8",    :collation => "utf8_unicode_ci"},
        193 => {:name => "utf8",    :collation => "utf8_icelandic_ci"},
        194 => {:name => "utf8",    :collation => "utf8_latvian_ci"},
        195 => {:name => "utf8",    :collation => "utf8_romanian_ci"},
        196 => {:name => "utf8",    :collation => "utf8_slovenian_ci"},
        197 => {:name => "utf8",    :collation => "utf8_polish_ci"},
        198 => {:name => "utf8",    :collation => "utf8_estonian_ci"},
        199 => {:name => "utf8",    :collation => "utf8_spanish_ci"},
        200 => {:name => "utf8",    :collation => "utf8_swedish_ci"},
        201 => {:name => "utf8",    :collation => "utf8_turkish_ci"},
        202 => {:name => "utf8",    :collation => "utf8_czech_ci"},
        203 => {:name => "utf8",    :collation => "utf8_danish_ci"},
        204 => {:name => "utf8",    :collation => "utf8_lithuanian_ci"},
        205 => {:name => "utf8",    :collation => "utf8_slovak_ci"},
        206 => {:name => "utf8",    :collation => "utf8_spanish2_ci"},
        207 => {:name => "utf8",    :collation => "utf8_roman_ci"},
        208 => {:name => "utf8",    :collation => "utf8_persian_ci"},
        209 => {:name => "utf8",    :collation => "utf8_esperanto_ci"},
        210 => {:name => "utf8",    :collation => "utf8_hungarian_ci"},
        254 => {:name => "utf8",    :collation => "utf8_general_cs"}
      }

      def self.encoding_from_charset(charset)
        CHARSET_MAP[charset.to_s.downcase]
      end

      def self.encoding_from_charset_code(code)
        if mapping = MYSQL_CHARSET_MAP[code]
          encoding_from_charset(mapping[:name])
        else
          nil
        end
      end
    end

    private
      def self.local_offset
        ::Time.local(2010).utc_offset.to_r / 86400
      end
  end
end
