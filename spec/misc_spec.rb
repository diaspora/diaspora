#    Copyright 2010 Diaspora Inc.
#
#    This file is part of Diaspora.
#
#    Diaspora is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    Diaspora is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with Diaspora.  If not, see <http://www.gnu.org/licenses/>.
#



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
