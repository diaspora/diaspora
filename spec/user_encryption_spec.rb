require File.dirname(__FILE__) + '/spec_helper'

describe 'user encryption' do
  before :all do
    #ctx = GPGME::Ctx.new
    #keys = ctx.keys
    #keys.each{|k| ctx.delete_key(k, true)}
    @u = User.new
    @u.email = "george@aol.com"
    @u.password = "bluepin7"
    @u.password_confirmation = "bluepin7"
    @u.url = "www.example.com"
    @u.profile = Profile.new( :first_name => "Bob", :last_name => "Smith" )
    @u.profile.save
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

  it 'should sign a message' do
    message = Factory.create(:status_message, :user => @u)
    message.verify_signature.should == true 
  end
end
