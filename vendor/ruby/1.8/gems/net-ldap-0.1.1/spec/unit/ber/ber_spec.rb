require 'spec_helper'

require 'net/ber'
require 'net/ldap'

describe "Ber encoding of various types" do
  def properly_encode_and_decode
    simple_matcher('properly encode and decode') do |given|
      given.to_ber.read_ber.should == given
    end
  end
  
  context "array" do
    it "should properly encode []" do
      [].should properly_encode_and_decode
    end 
  end
end