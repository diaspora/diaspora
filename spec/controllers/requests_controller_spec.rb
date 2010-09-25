#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.



require 'spec_helper'
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
