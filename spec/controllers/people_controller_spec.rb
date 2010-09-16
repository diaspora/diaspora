#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.



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
