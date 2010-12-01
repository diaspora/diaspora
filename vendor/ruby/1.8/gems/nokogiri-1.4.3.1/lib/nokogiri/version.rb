module Nokogiri
  # The version of Nokogiri you are using
  VERSION = '1.4.3.1'

  # More complete version information about libxml
  VERSION_INFO = {}
  VERSION_INFO['warnings']              = []
  VERSION_INFO['nokogiri']              = Nokogiri::VERSION
  VERSION_INFO['ruby']                  = {}
  VERSION_INFO['ruby']['version']       = ::RUBY_VERSION
  VERSION_INFO['ruby']['platform']      = ::RUBY_PLATFORM
  VERSION_INFO['ruby']['engine']        = defined?(RUBY_ENGINE) ? RUBY_ENGINE : 'mri'
  VERSION_INFO['ruby']['jruby']         = ::JRUBY_VERSION if RUBY_PLATFORM == "java"
  if defined?(LIBXML_VERSION)
    VERSION_INFO['libxml']              = {}
    VERSION_INFO['libxml']['binding']   = 'extension'
    VERSION_INFO['libxml']['compiled']  = LIBXML_VERSION
    VERSION_INFO['libxml']['loaded']    = LIBXML_PARSER_VERSION.scan(/^(.*)(..)(..)$/).first.collect{|j|j.to_i}.join(".")

    if VERSION_INFO['libxml']['compiled'] != VERSION_INFO['libxml']['loaded']
      warning = "Nokogiri was built against LibXML version #{VERSION_INFO['libxml']['compiled']}, but has dynamically loaded #{VERSION_INFO['libxml']['loaded']}"
      VERSION_INFO['warnings'] << warning
      warn "WARNING: #{warning}"
    end
  end

  def self.uses_libxml? # :nodoc:
    !Nokogiri::VERSION_INFO['libxml'].nil?
  end

  def self.ffi? # :nodoc:
    uses_libxml? && Nokogiri::VERSION_INFO['libxml']['binding'] == 'ffi'
  end

  def self.is_2_6_16? # :nodoc:
    Nokogiri::VERSION_INFO['libxml']['loaded'] <= '2.6.16'
  end
end
