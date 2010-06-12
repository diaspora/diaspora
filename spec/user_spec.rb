require 'spec_helper'

describe 'a user should be able to log into his seed' do
  before do
    User.all.each {|x| x.delete}
  end

  it 'should should have a name and password' do
    User.count.should == 0
    billy = User.create
    User.count.should == 1
  end

  it 'should be able to log into a page with a password' do
    billy = User.create(:password => "foobar")
    billy.password.should == "foobar"
  end

  
end
