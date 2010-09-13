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
 
describe PeopleController do
  render_views
  before do
    @user = Factory.create(:user)

    sign_in :user, @user   
    @user.aspect(:name => "lame-os")
  end

  it "index should yield search results for substring of person name" do
    pending "wait, what???"
    Person.should_receive(:search)
    get :index, :q => "Eu"
  end
  
  it 'should go to the current_user show page' do
    get :show, :id => @user.person.id
  end
end
