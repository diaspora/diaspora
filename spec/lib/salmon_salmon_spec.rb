#   Copyright (c) 2010, Disapora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.



require File.dirname(__FILE__) + '/../spec_helper'

describe Salmon do
  before do

    @user = Factory.create :user
    @post = @user.post :status_message, :message => "hi", :to => @user.aspect(:name => "sdg").id
    @sent_salmon = Salmon::SalmonSlap.create(@user, @post.to_diaspora_xml)
    @parsed_salmon = Salmon::SalmonSlap.parse @sent_salmon.to_xml
    stub_success("tom@tom.joindiaspora.com")
  end

  it 'should verify the signature on a roundtrip' do

    @sent_salmon.magic_sig.data.should == @parsed_salmon.magic_sig.data

    @sent_salmon.magic_sig.sig.should == @parsed_salmon.magic_sig.sig
    @sent_salmon.magic_sig.signable_string.should == @parsed_salmon.magic_sig.signable_string
    
    
    @parsed_salmon.verified_for_key?(OpenSSL::PKey::RSA.new(@user.exported_key)).should be true
    @sent_salmon.verified_for_key?(OpenSSL::PKey::RSA.new(@user.exported_key)).should be true
  end

  it 'should return the data so it can be "received"' do
  
    xml = @post.to_diaspora_xml

    @parsed_salmon.data.should == xml
  end

  it 'should parse out the author email' do
    @parsed_salmon.author_email.should == @user.person.email 
  end

  it 'should reference a local author' do
    @parsed_salmon.author.should == @user.person
  end

  it 'should reference a remote author' do
    @parsed_salmon.author_email = 'tom@tom.joindiaspora.com'
    @parsed_salmon.author.public_key.should_not be_nil
  end

  it 'should fail to reference a nonexistent remote author' do
    @parsed_salmon.author_email = 'idsfug@difgubhpsduh.rgd'
    proc {
      Redfinger.stub(:finger).and_return(nil) #Redfinger returns nil when there is no profile
      @parsed_salmon.author.real_name}.should raise_error /No webfinger profile found/
  end

end
