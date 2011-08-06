require 'spec_helper'

describe Service do

  before do
    @user = alice
    @post = @user.post(:status_message, :text => "hello", :to =>@user.aspects.first.id)
    @service = Services::Facebook.new(:access_token => "yeah")
    @user.services << @service
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
end
