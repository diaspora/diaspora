require 'spec_helper'

require 'net/ldap'

describe "BER serialisation (SSL)" do
  # Transmits str to #to and reads it back from #from. 
  #
  def transmit(str)
    to.write(str)
    to.close
    
    from.read
  end
    
  attr_reader :to, :from
  before(:each) do
    @from, @to = IO.pipe
    
    flexmock(OpenSSL::SSL::SSLSocket).
      new_instances.should_receive(:connect => nil)
              
    @to   = Net::LDAP::Connection.wrap_with_ssl(to)
    @from = Net::LDAP::Connection.wrap_with_ssl(from)
  end
  
  it "should transmit strings" do
    transmit('foo').should == 'foo'
  end 
  it "should correctly transmit numbers" do
    to.write 1234.to_ber
    from.read_ber.should == 1234
  end 
end