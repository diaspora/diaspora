require 'spec_helper'
require 'net/ldap/dn'

describe Net::LDAP::DN do
  describe "<- .construct" do
    attr_reader :dn

    before(:each) do
      @dn = Net::LDAP::DN.new('cn', ',+"\\<>;', 'ou=company')
    end

    it "should construct a Net::LDAP::DN" do
      dn.should be_an_instance_of(Net::LDAP::DN)
    end 

    it "should escape all the required characters" do
      dn.to_s.should == 'cn=\\,\\+\\"\\\\\\<\\>\\;,ou=company'
    end
  end

  describe "<- .to_a" do
    context "parsing" do
      {
        'cn=James, ou=Company\\,\\20LLC' => ['cn','James','ou','Company, LLC'],
        'cn =  \ James , ou  =  "Comp\28ny"  ' => ['cn',' James','ou','Comp(ny'],
        '1.23.4=  #A3B4D5  ,ou=Company' => ['1.23.4','#A3B4D5','ou','Company'],
      }.each do |key, value|
        context "(#{key})" do
          attr_reader :dn

          before(:each) do
            @dn = Net::LDAP::DN.new(key)
          end

          it "should decode into a Net::LDAP::DN" do
            dn.should be_an_instance_of(Net::LDAP::DN)
          end

          it "should return the correct array" do
            dn.to_a.should == value
          end
        end
      end
    end

    context "parsing bad input" do
      [
        'cn=James,',
        'cn=#aa aa',
        'cn="James',
        'cn=J\ames',
        'cn=\\',
        '1.2.d=Value',
        'd1.2=Value',
      ].each do |value|
        context "(#{value})" do
          attr_reader :dn

          before(:each) do
            @dn = Net::LDAP::DN.new(value)
          end

          it "should decode into a Net::LDAP::DN" do
            dn.should be_an_instance_of(Net::LDAP::DN)
          end

          it "should raise an error on parsing" do
            lambda { dn.to_a }.should raise_error
          end
        end
      end
    end
  end

  describe "<- .escape(str)" do
    it "should escape ,, +, \", \\, <, >, and ;" do
      Net::LDAP::DN.escape(',+"\\<>;').should == '\\,\\+\\"\\\\\\<\\>\\;'
    end 
  end
end
