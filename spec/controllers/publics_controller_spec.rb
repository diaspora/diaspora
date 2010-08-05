require File.dirname(__FILE__) + '/../spec_helper'
 
describe PublicsController do
 render_views
  
  before do
    @user = Factory.create(:user, :profile => Profile.new( :first_name => "bob", :last_name => "smith"))
    @user.person.save
    request.env['warden'] = mock_model(Warden, :authenticate? => @user, :authenticate! => @user, :authenticate => @user)
  end

  describe 'receive endpoint' do

    it 'should accept a post from anohter node and save the information' do
      
      person = Factory.create(:person)
      message = StatusMessage.new(:message => 'foo', :person => person)
      StatusMessage.all.count.should == 0
      post :receive, {:xml => Post.build_xml_for(message)}
      StatusMessage.all.count.should == 1
    end
  end

end
