require File.dirname(__FILE__) + '/../spec_helper'

describe SocketRenderer do
  before do
    SocketRenderer.instantiate_view
    @user = Factory.create(:user, :email => "bob@jones.com")
    @user.profile = Factory.build(:profile, :person => @user)
  end

  it 'should render a partial for a status message' do
    message = Factory.create(:status_message, :person => @user)
    html = SocketRenderer.view_for message
    html.include? message.message
  end

  it 'should prepare a class/view hash' do
      message = Factory.create(:status_message, :person => @user)
  
      hash = SocketRenderer.view_hash(message)
      hash[:class].should == "status_messages"
      
  end
end
