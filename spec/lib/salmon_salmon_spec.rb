require File.dirname(__FILE__) + '/../spec_helper'



require 'lib/salmon/salmon'
include ApplicationHelper 
include Salmon



describe Salmon do
  before do

    @user = Factory.create :user
    @post = @user.post :status_message, :message => "hi", :to => @user.group(:name => "sdg").id
    @sent_salmon = Salmon::SalmonSlap.create(@user, @post.to_diaspora_xml)
    @parsed_salmon = Salmon::SalmonSlap.parse @sent_salmon.to_xml
  end

  it 'should verify the signature on a roundtrip' do

    @sent_salmon.magic_sig.data.should == @parsed_salmon.magic_sig.data

    @sent_salmon.magic_sig.sig.should == @parsed_salmon.magic_sig.sig
    @sent_salmon.magic_sig.signable_string.should == @parsed_salmon.magic_sig.signable_string
    
    
    @parsed_salmon.verified_for_key?(OpenSSL::PKey::RSA.new(@user.exported_key)).should be true
    @sent_salmon.verified_for_key?(OpenSSL::PKey::RSA.new(@user.exported_key)).should be true
  end
  
  it 'should have an accessible queue' do
    Salmon::QUEUE.is_a?(MessageHandler).should be true
  end

  it 'should push to a url' do
    QUEUE.should_receive(:add_post_request)
    @sent_salmon.push_to_url("example.com")
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
    proc {@parsed_salmon.author.real_name}.should raise_error /not found/
  end

end
