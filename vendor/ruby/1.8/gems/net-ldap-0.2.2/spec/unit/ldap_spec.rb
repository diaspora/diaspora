require 'spec_helper'

describe Net::LDAP::Connection do
  describe "initialize" do
    context "when host is not responding" do
      before(:each) do
        flexmock(TCPSocket).
          should_receive(:new).and_raise(Errno::ECONNREFUSED)
      end
      
      it "should raise LdapError" do
        lambda {
          Net::LDAP::Connection.new(
            :server => 'test.mocked.com', 
            :port   => 636)
        }.should raise_error(Net::LDAP::LdapError)
      end
    end
    context "when host is blocking the port" do
      before(:each) do
        flexmock(TCPSocket).
          should_receive(:new).and_raise(SocketError)
      end
      
      it "should raise LdapError" do
        lambda {
          Net::LDAP::Connection.new(
            :server => 'test.mocked.com', 
            :port   => 636)
        }.should raise_error(Net::LDAP::LdapError)
      end
    end
    context "on other exceptions" do
      before(:each) do
        flexmock(TCPSocket).
          should_receive(:new).and_raise(NameError)
      end
      
      it "should rethrow the exception" do
        lambda {
          Net::LDAP::Connection.new(
            :server => 'test.mocked.com', 
            :port   => 636)
        }.should raise_error(NameError)
      end
    end
  end
end