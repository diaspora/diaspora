require 'spec_helper'

describe Net::LDAP::Entry do
  attr_reader :entry
  before(:each) do
    @entry = Net::LDAP::Entry.from_single_ldif_string(
      %Q{dn: something
foo: foo
barAttribute: bar
      }
    )
  end

  describe "entry access" do
    it "should always respond to #dn" do
      entry.should respond_to(:dn)
    end 
    
    context "<- #foo" do
      it "should respond_to?" do
        entry.should respond_to(:foo)
      end 
      it "should return 'foo'" do
        entry.foo.should == ['foo']
      end
    end
    context "<- #Foo" do
      it "should respond_to?" do
        entry.should respond_to(:Foo)
      end 
      it "should return 'foo'" do
        entry.foo.should == ['foo']
      end 
    end
    context "<- #foo=" do
      it "should respond_to?" do
        entry.should respond_to(:foo=)
      end 
      it "should set 'foo'" do
        entry.foo= 'bar'
        entry.foo.should == ['bar']
      end 
    end
    context "<- #fOo=" do
      it "should return 'foo'" do
        entry.fOo= 'bar'
        entry.fOo.should == ['bar']
      end 
    end
  end
end