#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe 'user encryption' do
  before do
    @user = Factory.create(:user)
    @aspect = @user.aspect(:name => 'dudes')
  end

  describe 'key exchange on friending' do

    it 'should receive and marshal a public key from a request' do
      remote_user = Factory.build(:user)
      remote_user.encryption_key.nil?.should== false

      deliverable = Object.new
      deliverable.stub!(:deliver)
      Notifier.stub!(:new_request).and_return(deliverable)
      Person.should_receive(:by_account_identifier).and_return(remote_user.person)
      remote_user.should_receive(:push_to_people).and_return(true) 
      #should move this to friend request, but i found it here
      id = remote_user.person.id
      original_key = remote_user.exported_key

      request = remote_user.send_friend_request_to(
        @user.person, remote_user.aspect(:name => "temp"))

      xml = remote_user.salmon(request).xml_for(@user)

      remote_user.person.delete
      remote_user.delete

      person_count = Person.all.count
      @user.receive_salmon xml
        
      Person.all.count.should == person_count + 1
      new_person = Person.first(:id => id)
      new_person.exported_key.should == original_key
    end
  end

  describe 'encryption' do
    it 'should encrypt a string' do
      string = "Secretsauce"
      ciphertext = @user.encrypt string
      ciphertext.include?(string).should be false
      @user.decrypt(ciphertext).should == string
    end
  end
end
