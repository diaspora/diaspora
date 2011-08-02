require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe Typhoeus::Utils do
  # Taken from Rack 1.2.1
  describe "#escape" do
    it "should escape correctly" do
      Typhoeus::Utils.escape("fo<o>bar").should == "fo%3Co%3Ebar"
      Typhoeus::Utils.escape("a space").should == "a+space"
      Typhoeus::Utils.escape("q1!2\"'w$5&7/z8)?\\").
        should == "q1%212%22%27w%245%267%2Fz8%29%3F%5C"
    end

    it "should escape correctly for multibyte characters" do
      matz_name = "\xE3\x81\xBE\xE3\x81\xA4\xE3\x82\x82\xE3\x81\xA8".unpack("a*")[0] # Matsumoto
      matz_name.force_encoding("UTF-8") if matz_name.respond_to? :force_encoding
      Typhoeus::Utils.escape(matz_name).should == '%E3%81%BE%E3%81%A4%E3%82%82%E3%81%A8'
      matz_name_sep = "\xE3\x81\xBE\xE3\x81\xA4 \xE3\x82\x82\xE3\x81\xA8".unpack("a*")[0] # Matsu moto
      matz_name_sep.force_encoding("UTF-8") if matz_name_sep.respond_to? :force_encoding
      Typhoeus::Utils.escape(matz_name_sep).should == '%E3%81%BE%E3%81%A4+%E3%82%82%E3%81%A8'
    end
  end
end
