#    Copyright 2010 Diaspora Inc.
#
#    This file is part of Diaspora.
#
#    Diaspora is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    Diaspora is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with Diaspora.  If not, see <http://www.gnu.org/licenses/>.
#



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
