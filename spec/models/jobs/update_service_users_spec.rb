require 'spec_helper'

describe Jobs::UpdateServiceUsers do
  before do
    @user = alice
    @post = @user.post(:status_message, :text => "hello", :to =>@user.aspects.first.id)
    @service = Services::Facebook.new(:access_token => "yeah")
    @user.services << @service
  end
  
  it 'calls the update_friends for the service' do
    Service.stub!(:find).and_return(@service)
    @service.should_receive(:save_friends)
    
    Jobs::UpdateServiceUsers.perform(@service.id)
  end

 end
