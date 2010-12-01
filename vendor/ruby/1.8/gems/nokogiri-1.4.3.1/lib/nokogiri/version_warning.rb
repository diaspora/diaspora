module Nokogiri
  if self.is_2_6_16?
    VERSION_INFO['warnings'] << "libxml 2.6.16 is old and buggy."
    if !defined?(I_KNOW_I_AM_USING_AN_OLD_AND_BUGGY_VERSION_OF_LIBXML2)
      warn <<-eom
HI.  You're using libxml2 version 2.6.16 which is over 4 years old and has
plenty of bugs.  We suggest that for maximum HTML/XML parsing pleasure, you
upgrade your version of libxml2 and re-install nokogiri.  If you like using
libxml2 version 2.6.16, but don't like this warning, please define the constant
I_KNOW_I_AM_USING_AN_OLD_AND_BUGGY_VERSION_OF_LIBXML2 before requring nokogiri.
      eom
    end
  end
end
