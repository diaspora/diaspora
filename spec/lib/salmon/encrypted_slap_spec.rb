#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Salmon::EncryptedSlap do
  before do
    @post = alice.post(:status_message, :text => "hi", :to => alice.aspects.create(:name => "abcd").id)
    @created_salmon = Salmon::EncryptedSlap.create_by_user_and_activity(alice, @post.to_diaspora_xml)
  end

  describe '#create' do
    it 'makes the data in the signature encrypted with that key' do
      key_hash = {'key' => @created_salmon.aes_key, 'iv' => @created_salmon.iv}
      decoded_string = Salmon::EncryptedSlap.decode64url(@created_salmon.magic_sig.data)
      alice.aes_decrypt(decoded_string, key_hash).should == @post.to_diaspora_xml
    end

    it 'sets aes and iv key' do
      @created_salmon.aes_key.should_not be_nil
      @created_salmon.iv.should_not be_nil
    end
  end

  context 'marshalling' do
    let(:xml)   {@created_salmon.xml_for(eve.person)}
    let(:parsed_salmon) { Salmon::EncryptedSlap.from_xml(xml, alice)}

    it 'should parse out the aes key' do
      parsed_salmon.aes_key.should == @created_salmon.aes_key
    end

    it 'should parse out the iv' do
      parsed_salmon.iv.should == @created_salmon.iv
    end

    it 'contains the original data' do
      parsed_salmon.parsed_data.should == @post.to_diaspora_xml
    end
  end

  describe '#xml_for' do
    let(:xml) {@created_salmon.xml_for eve.person}

    it 'has a encrypted header field' do
      xml.include?("encrypted_header").should be true
    end

    it 'the encrypted_header field should contain the aes key' do
      doc = Nokogiri::XML(xml)
      decrypted_header = eve.decrypt(doc.search('encrypted_header').text)
      decrypted_header.include?(@created_salmon.aes_key).should be true
    end
  end
end

