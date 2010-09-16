#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.



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

  it 'should factory create a user with a person saved' do
    user = Factory.create(:user)
    loaded_user = User.first(:id => user.id)
    loaded_user.person.owner_id.should == user.id
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
