#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
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

  describe "#process_header" do
    before do
      @new_slap = Salmon::EncryptedSlap.new
      @new_slap.process_header(Nokogiri::XML(@created_salmon.plaintext_header))
    end

    it 'sets the author id' do
      @new_slap.author_id.should == alice.diaspora_handle
    end

    it 'sets the aes_key' do
      @new_slap.aes_key.should == @created_salmon.aes_key
    end

    it 'sets the aes_key' do
      @new_slap.iv.should == @created_salmon.iv
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
    before do
      @xml = @created_salmon.xml_for eve.person
    end

    it 'has a encrypted header field' do
      doc = Nokogiri::XML(@xml)
      doc.find("encrypted_header").should_not be_blank
    end
    
    context "encrypted header" do
      before do
        doc = Nokogiri::XML(@xml)
        decrypted_header = eve.decrypt(doc.search('encrypted_header').text)
        @dh_doc = Nokogiri::XML(decrypted_header)
      end

      it 'contains the aes key' do
        @dh_doc.search('aes_key').map(&:text).should == [@created_salmon.aes_key]
      end

      it 'contains the initialization vector' do
        @dh_doc.search('iv').map(&:text).should == [@created_salmon.iv]
      end

      it 'contains the author id' do
        @dh_doc.search('author_id').map(&:text).should == [alice.diaspora_handle]
      end
    end
  end
end

