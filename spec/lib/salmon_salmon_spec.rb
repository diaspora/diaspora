require File.dirname(__FILE__) + '/../spec_helper'



require 'lib/salmon/salmon'
include ApplicationHelper 
include Salmon



describe Salmon do
  it 'should verify the signature on a roundtrip' do
    @user = Factory.create :user
    @post = @user.post :status_message, :message => "hi"
    x = Salmon::SalmonSlap.create(@user, @post.to_diaspora_xml)
  
    z = Salmon::SalmonSlap.parse x.to_xml

    x.magic_sig.data.should == z.magic_sig.data

    x.magic_sig.sig.should == z.magic_sig.sig
    x.magic_sig.signable_string.should == z.magic_sig.signable_string
    
    
    x.verified_for_key?(OpenSSL::PKey::RSA.new(@user.export_key)).should be true
    z.verified_for_key?(OpenSSL::PKey::RSA.new(@user.export_key)).should be true
  end


  it 'should return the data so it can be "received"' do
    @user = Factory.create :user
    @post = @user.post :status_message, :message => "hi"
    x = Salmon::SalmonSlap.create(@user, @post.to_diaspora_xml)
  
    z = Salmon::SalmonSlap.parse x.to_xml

    xml = @post.to_diaspora_xml

    z.data.should == xml
  end
end
