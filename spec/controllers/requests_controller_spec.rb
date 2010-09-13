require File.dirname(__FILE__) + '/../spec_helper'
include ApplicationHelper 
include RequestsHelper 
describe RequestsController do
 render_views
  before do 
    @user = Factory.create :user
    @tom = Redfinger.finger('tom@tom.joindiaspora.com')
    @evan = Redfinger.finger('evan@status.net')
    @max = Redfinger.finger('mbs348@gmail.com')
    sign_in :user, @user
    stub!(:current_user).and_return @user
  end
  it 'should return the correct tag and url for a given address' do
    relationship_flow('tom@tom.joindiaspora.com')[:friend].receive_url.include?("receive/user").should ==  true
  end
end
