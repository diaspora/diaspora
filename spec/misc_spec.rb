require File.dirname(__FILE__) + '/spec_helper'
 
describe 'making sure the spec runner works' do

  it 'should not delete the database mid-spec' do
    User.count.should == 0
    Factory.create(:user)
    User.count.should == 1
  end
  
  it 'should make sure the last user no longer exsists' do
    User.count.should == 0
  end
  
  describe 'testing a before do block' do
    before do
      Factory.create(:user)
      
    end
    
    it 'should have cleaned before the before do block runs' do
      User.count.should == 1
    end
    
  end
end
