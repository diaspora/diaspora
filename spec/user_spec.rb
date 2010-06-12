require 'spec_helper'

describe 'a user should be able to log into his seed' do
  before do
    User.delete_all
  end

  it 'should should have a name and password' do
    User.count.should == 0
    billy = User.new
    User.count.should == 0
    billy.save
    User.count.should == 0
    
    
  end

  it 'should be able to log into a page with a password' do
    billy = User.create(:password => "foobar")
    billy.password.should == "foobar"
  end

  
end
