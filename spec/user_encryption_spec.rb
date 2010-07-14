require File.dirname(__FILE__) + '/spec_helper'
include ApplicationHelper

describe 'user encryption' do
  before :all do
    #ctx = GPGME::Ctx.new
    #keys = ctx.keys
    #keys.each{|k| ctx.delete_key(k, true)}
    
  end
  before do
    unstub_mocha_stubs
    @u = Factory.create(:user)
    @u.send(:assign_key)
    @u.save
    @person = Factory.create(:person,
      :key_fingerprint => GPGME.list_keys("Remote Friend").first.subkeys.first.fpr,
      :profile => Profile.create(:first_name => 'Remote',
                                :last_name => 'Friend'),
      :email => 'somewhere@else.com',
      :url => 'http://distant-example.com/',
      :key_fingerprint => '57F553EE2C230991566B7C60D3638485F3960087')

  end

  after  do
    stub_signature_verification
    #gpgdir = File.expand_path("../../db/gpg-#{Rails.env}", __FILE__)
    #ctx = GPGME::Ctx.new
    #keys = ctx.keys
    #keys.each{|k| ctx.delete_key(k, true)}
  end
  
  it 'should remove the key from the keyring on person destroy' do
    pending "We can implement deleting from the keyring later, its annoying to test b/c no stub any instance of"
    person = Factory.create :person
    keyid = person.key_fingerprint
    original_key = person.export_key
    GPGME.list_keys(keyid).count.should be 1
    person.destroy
    GPGME.list_keys(keyid).count.should be 0
    GPGME.import(original_key)
    GPGME.list_keys(keyid).count.should be 1
  end

  it 'should have a key fingerprint' do
    @u.key_fingerprint.should_not be nil
  end

  it 'should retrieve a user key' do
    @u.key.subkeys[0].fpr.should  == @u.key_fingerprint
  end

  describe 'key exchange on friending' do
       it 'should send over a public key' do
      Comment.send(:class_variable_get, :@@queue).stub!(:add_post_request)
      request = @u.send_friend_request_to("http://example.com/")
      Request.build_xml_for([request]).include?( @u.export_key).should be true
    end

    it 'should receive and marshal a public key from a request' do
      person = Factory.build(:person, :url => "http://test.url/" )
      person.key_fingerprint.nil?.should== false
      #should move this to friend request, but i found it here 
      f = person.key_fingerprint
      id = person.id
      original_key = person.export_key
      
      request = Request.instantiate(:to =>"http://www.google.com/", :from => person)
      
      xml = Request.build_xml_for [request]
      person.destroy
      store_objects_from_xml(xml)
      Person.all.count.should == 3 
      new_person = Person.first(:url => "http://test.url/")
      new_person.key_fingerprint.nil?.should == false
      new_person.id.should == id
      new_person.key_fingerprint.should == f
      new_person.export_key.should == original_key
    end 
  end

  describe 'signing and verifying' do

    it 'should sign a message on create' do
      message = Factory.create(:status_message, :person => @u)
      message.verify_signature.should be true 
    end
    
    it 'should not be able to verify a message from a person without a key' do 
      person = Factory.create(:person, :key_fingerprint => "123")
      message = Factory.build(:status_message, :person => person)
      message.save(:validate => false)
      message.verify_signature.should be false
    end
    
    it 'should verify a remote signature' do 
      message = Factory.build(:status_message, :person => @person)
      message.owner_signature = GPGME.sign(message.signable_string, nil,
        {:mode => GPGME::SIG_MODE_DETACH, :armor => true, :signers => [@person.key]})
      message.save(:validate => false)
      message.verify_signature.should be true
    end
    
    it 'should know if the signature is from the wrong person' do
      message = Factory.build(:status_message, :person => @person)
      message.save(:validate => false)
      message.owner_signature = GPGME.sign(message.signable_string, nil,
        {:mode => GPGME::SIG_MODE_DETACH, :armor => true, :signers => [@person.key]})
      message.person = @u
      message.verify_signature.should be false
    end
   
    it 'should know if the signature is for the wrong text' do
      message = Factory.build(:status_message, :person => @person)
      message.owner_signature = GPGME.sign(message.signable_string, nil,
        {:mode => GPGME::SIG_MODE_DETACH, :armor => true, :signers => [@person.key]})
      message.message = 'I love VENISON'
      message.save(:validate => false)
      message.verify_signature.should be false
    end
  end

  describe 'sending and recieving signatures' do
    it 'should contain the signature in the xml' do
      message = Factory.create(:status_message, :person => @u)
      xml = message.to_xml.to_s
      xml.include?(message.owner_signature).should be true
    end
    it 'the signature should be verified on marshaling' do
      message = Factory.build(:status_message, :person => @person)
      message.owner_signature = GPGME.sign(message.signable_string, nil,
        {:mode => GPGME::SIG_MODE_DETACH, :armor => true, :signers => [@u.key]})
      message.save
      xml = Post.build_xml_for([message])
      message.destroy
      Post.count.should be 0
      store_objects_from_xml(xml)
      Post.count.should be 0
    end

  end
end
