#   Copyright (c) 2010, Disapora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.



require File.dirname(__FILE__) + '/../spec_helper'

include ApplicationHelper 
describe ApplicationHelper do
  before do
    @user = Factory.create(:user)
    @person = Factory.create(:person)
  end


  it "should provide a correct show path for a given person" do
    person_url(@person).should == "/people/#{@person.id}"
  end

  it "should provide a correct show path for a given user" do
    person_url(@user).should == "/users/#{@user.id}"
  end

end
