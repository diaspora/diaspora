require File.dirname(__FILE__) + '/../spec_helper'

describe Group do
  before do
    @user = Factory.create(:user)
    @friend = Factory.create(:person)
  end

  describe 'creation' do
    it 'should have a name' do
      group = @user.group(:name => 'losers')
      group.name.should == "losers"
    end
  end
  
  describe 'querying' do
    before do
      @group = @user.group(:name => 'losers', :people => [@friend])
    end

    it 'belong to a user' do
      @group.user.id.should == @user.id
      @user.groups.size.should == 1
      @user.groups.first.id.should == @group.id
    end

    it 'should have people' do
      @group.people.all.include?(@friend).should be true
      @group.people.size.should == 1
    end
  end
end
