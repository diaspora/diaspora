require 'spec_helper'

describe Service do

  before do
    @post = alice.post(:status_message, :text => "hello", :to => alice.aspects.first.id)
    @service = Services::Facebook.new(:access_token => "yeah", :uid => 1)
    alice.services << @service
  end

  it 'is unique to a user by service type and uid' do
    @service.save

    second_service = Services::Facebook.new(:access_token => "yeah", :uid => 1)

    alice.services << second_service
    alice.services.last.save
    alice.services.last.should be_invalid
  end

  it 'destroys the associated service_user' do
    @service.service_users = [ServiceUser.create(:service_id => @service.id,
                                                 :uid => "abc123",
                                                 :photo_url => "a.jpg",
                                                 :name => "a",
                                                :person_id => bob.person.id)]
    lambda{
      @service.destroy
    }.should change(ServiceUser, :count).by(-1)
  end

  it 'by default has no profile photo url' do
    Service.new.profile_photo_url.should be_nil
  end
end
