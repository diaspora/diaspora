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
include RequestsHelper 
describe RequestsController do
 render_views
  before do 
    @user = Factory.create :user
    stub_success("tom@tom.joindiaspora.com")

    @tom = Redfinger.finger('tom@tom.joindiaspora.com')
    sign_in :user, @user
    stub!(:current_user).and_return @user
  end
  it 'should return the correct tag and url for a given address' do
    relationship_flow('tom@tom.joindiaspora.com')[:friend].receive_url.include?("receive/user").should ==  true
  end
end
