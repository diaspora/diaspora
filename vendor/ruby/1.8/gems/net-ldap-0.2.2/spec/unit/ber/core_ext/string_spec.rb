require 'spec_helper'
require 'metaid'

describe String, "when extended with BER core extensions" do
  describe "<- #read_ber! (consuming read_ber method)" do
    context "when passed an ldap bind request and some extra data" do
      attr_reader :str, :result
      before(:each) do
        @str = "0$\002\001\001`\037\002\001\003\004\rAdministrator\200\vad_is_bogus UNCONSUMED" 
        @result = str.read_ber!(Net::LDAP::AsnSyntax)
      end
      
      it "should correctly parse the ber message" do
        result.should == [1, [3, "Administrator", "ad_is_bogus"]]
      end 
      it "should leave unconsumed part of message in place" do
        str.should == " UNCONSUMED"
      end

      context "if an exception occurs during #read_ber" do
        attr_reader :initial_value
        before(:each) do
          stub_exception_class = Class.new(StandardError)
          
          @initial_value = "0$\002\001\001`\037\002\001\003\004\rAdministrator\200\vad_is_bogus" 
          @str = initial_value.dup 

          # Defines a string
          io = StringIO.new(initial_value)
          io.meta_def :read_ber do |syntax|
            read
            raise stub_exception_class
          end
          flexmock(StringIO).should_receive(:new).and_return(io)
          
          begin
            str.read_ber!(Net::LDAP::AsnSyntax)            
          rescue stub_exception_class
            # EMPTY ON PURPOSE
          else
            raise "The stub code should raise an exception!"
          end
        end
        
        it "should not modify string" do
          str.should == initial_value
        end
      end
    end
  end
end
