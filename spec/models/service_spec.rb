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

  it 'by default has no profile photo url' do
    Service.new.profile_photo_url.should be_nil
  end
  
end
