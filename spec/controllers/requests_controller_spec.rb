#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe RequestsController do
  render_views
  before do
    @user = Factory.create(:user)

    sign_in :user, @user
    @user.aspect(:name => "lame-os")
  end

  it "should not error out when requesting to be friends with yourself" do
    put("create", "request" => {
      "destination_url" => @user.diaspora_handle,
      "aspect_id" => @user.aspects[0].id 
      } 
    )
    response.should redirect_to aspect_path(@user.aspects[0].id.to_s)
  end

end
