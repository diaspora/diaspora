require File.dirname(__FILE__) + '/../spec_helper'

include PublicsHelper 
describe PublicsHelper do
  before do
    @user = Factory.create(:user)
    @person = Factory.create(:person)
  end

  it 'should be able to give me the terse url for webfinger' do
     @user.person.url = "http://example.com/"

      terse_url( @user.person.url ).should == 'example.com'
  end
end
