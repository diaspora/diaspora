#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe RequestsController do
  render_views
  before do
    @user = make_user

    sign_in :user, @user
    @user.aspects.create(:name => "lame-os")
  end

  it "should not error out when requesting to be friends with yourself" do
    put("create", "request" => {
      "destination_url" => @user.diaspora_handle,
      "aspect_id" => @user.aspects[0].id 
      } 
    )
    response.should redirect_to aspects_manage_path 
  end

  it "should not error out when requesting an invalid identity" do
    put("create", "request" => {
      "destination_url" => "not_a_@valid_email",
      "aspect_id" => @user.aspects[0].id 
      } 
    )
    response.should redirect_to aspects_manage_path
  end

  it "should not error out when requesting an invalid identity with a port number" do
    put("create", "request" => {
      "destination_url" => "johndoe@email.com:3000",
      "aspect_id" => @user.aspects[0].id 
      } 
    )
    response.should redirect_to aspects_manage_path
  end

  it "should not error out when requesting an identity from an invalid server" do
    stub_request(:get, /notadiasporaserver\.com/).to_raise(Errno::ETIMEDOUT)
    put("create", "request" => {
      "destination_url" => "johndoe@notadiasporaserver.com",
      "aspect_id" => @user.aspects[0].id 
      } 
    )
    response.should redirect_to aspects_manage_path
  end

  it 'should redirect to the page which you called it from ' do
    pending "i need to figure out how to do this"
  end

  it 'should not blow up if there is a problem mid way thru the webfinger process' do
    pending "i need to do this tomorrow"
  end
end
