require File.dirname(__FILE__) + '/spec_helper'
include ApplicationHelper

describe 'user encryption' do
  before :all do
    #ctx = GPGME::Ctx.new
    #keys = ctx.keys
    #keys.each{|k| ctx.delete_key(k, true)}
    
  end
  before do
    @u = Factory.create(:user)
    @u.send(:assign_key)
    @u.save
  end
#  after :all do
    #gpgdir = File.expand_path("../../db/gpg-#{Rails.env}", __FILE__)
    #ctx = GPGME::Ctx.new
    #keys = ctx.keys
    #keys.each{|k| ctx.delete_key(k, true)}
  #end
  
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
      puts "THIS IS FUCKED UP"
      person  = Factory.build(:person ) 
      original_key = person.export_key 
      person.save
      
      request = Request.instantiate(:to =>"http://www.google.com/", :from => person)
      
      xml = Request.build_xml_for [request]
      person.destroy
      
      store_objects_from_xml(xml)
      
      new_person = Person.first(:url => request.callback_url)
      new_person.export_key.should == original_key 
    end
  end

  describe 'signing and verifying' do
    
    it 'should sign a message on create' do
      message = Factory.create(:status_message, :person => @u)
      message.verify_signature.should be true 
    end
    
    it 'should not be able to verify a message from a person without a key' do 
      person = Factory.create(:person)
      message = Factory.create(:status_message, :person => person)
      message.verify_signature.should be false
    end
    
    it 'should know if the signature is from the wrong person' do
      pending
    end
    
  end
end
