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

describe Profile do
  before do
    @person = Factory.build(:person)
  end

  describe 'requirements' do
    it "should include a first name" do
      @person.profile = Factory.build(:profile,:first_name => nil)
      @person.profile.valid?.should be false
      @person.profile.first_name = "Bob"
      @person.profile.valid?.should be true
    end
   
    it "should include a last name" do
      @person.profile = Factory.build(:profile, :last_name => nil)
      @person.profile.valid?.should be false
      @person.profile.last_name = "Smith"
      @person.profile.valid?.should be true
    end 

  end

end

