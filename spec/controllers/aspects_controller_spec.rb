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



require File.dirname(__FILE__) + '/../spec_helper'
include ApplicationHelper 
describe AspectsController do
 render_views
  before do
    @user = Factory.create(:user)
    @user.aspect(:name => "lame-os")
    @person = Factory.create(:person)
    sign_in :user, @user   
  end

  it "on index sets a variable containing all a user's friends when a user is signed in" do
    sign_in :user, @user   
    Factory.create :person
    get :index
    assigns[:friends].should == @user.friends
  end

end
