require 'spec_helper'

describe Net::LDAP::Filter do
  describe "<- .ex(attr, value)" do
    context "('foo', 'bar')" do
      attr_reader :filter
      before(:each) do
        @filter = Net::LDAP::Filter.ex('foo', 'bar')
      end
      it "should convert to 'foo:=bar'" do
        filter.to_s.should == '(foo:=bar)'
      end 
      it "should survive roundtrip via to_s/from_rfc2254" do
        Net::LDAP::Filter.from_rfc2254(filter.to_s).should == filter
      end 
      it "should survive roundtrip conversion to/from ber" do
        ber = filter.to_ber
        Net::LDAP::Filter.parse_ber(ber.read_ber(Net::LDAP::AsnSyntax)).should ==
          filter
      end 
    end
    context "various legal inputs" do
      [
        '(o:dn:=Ace Industry)', 
        '(:dn:2.4.8.10:=Dino)', 
        '(cn:dn:1.2.3.4.5:=John Smith)', 
        '(sn:dn:2.4.6.8.10:=Barbara Jones)',
        '(&(sn:dn:2.4.6.8.10:=Barbara Jones))'
      ].each do |filter_str|
        context "from_rfc2254(#{filter_str.inspect})" do
          attr_reader :filter
          before(:each) do
            @filter = Net::LDAP::Filter.from_rfc2254(filter_str)
          end

          it "should decode into a Net::LDAP::Filter" do
            filter.should be_an_instance_of(Net::LDAP::Filter)
          end 
          it "should survive roundtrip conversion to/from ber" do
            ber = filter.to_ber
            Net::LDAP::Filter.parse_ber(ber.read_ber(Net::LDAP::AsnSyntax)).should ==
              filter
          end 
        end
      end
    end
  end
  describe "<- .construct" do
    it "should accept apostrophes in filters (regression)" do
      Net::LDAP::Filter.construct("uid=O'Keefe").to_rfc2254.should == "(uid=O'Keefe)"
    end 
  end

  describe "convenience filter constructors" do
    def eq(attribute, value)
      described_class.eq(attribute, value)
    end
    describe "<- .equals(attr, val)" do
      it "should delegate to .eq with escaping" do
        described_class.equals('dn', 'f*oo').should == eq('dn', 'f\2Aoo')
      end 
    end
    describe "<- .begins(attr, val)" do
      it "should delegate to .eq with escaping" do
        described_class.begins('dn', 'f*oo').should == eq('dn', 'f\2Aoo*')
      end 
    end
    describe "<- .ends(attr, val)" do
      it "should delegate to .eq with escaping" do
        described_class.ends('dn', 'f*oo').should == eq('dn', '*f\2Aoo')
      end 
    end
    describe "<- .contains(attr, val)" do
      it "should delegate to .eq with escaping" do
        described_class.contains('dn', 'f*oo').should == eq('dn', '*f\2Aoo*')
      end 
    end
  end
  describe "<- .escape(str)" do
    it "should escape nul, *, (, ) and \\" do
      Net::LDAP::Filter.escape("\0*()\\").should == "\\00\\2A\\28\\29\\5C"
    end 
  end
end
