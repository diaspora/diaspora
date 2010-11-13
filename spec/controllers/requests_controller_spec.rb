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

  describe '#create' do
    it "redirects when requesting to be contacts with yourself" do
      put(:create, {
        :destination_handle => @user.diaspora_handle,
        :aspect_id => @user.aspects[0].id 
        } 
      )
      response.should redirect_to aspects_manage_path 
    end

    it "flashes and redirects when requesting an invalid identity" do
      put(:create, {
        :destination_handle => "not_a_@valid_email",
        :aspect_id => @user.aspects[0].id 
        } 
      )
      flash[:error].should_not be_blank
      response.should redirect_to aspects_manage_path
    end

    it "flashes and redirects when requesting an invalid identity with a port number" do
      put(:create, {
        :destination_handle => "johndoe@email.com:3000",
        :aspect_id => @user.aspects[0].id 
        } 
      )
      flash[:error].should_not be_blank
      response.should redirect_to aspects_manage_path
    end

    it "redirects when requesting an identity from an invalid server" do
      stub_request(:get, /notadiasporaserver\.com/).to_raise(Errno::ETIMEDOUT)
      put(:create, {
        :destination_handle => "johndoe@notadiasporaserver.com",
        :aspect_id => @user.aspects[0].id 
        } 
      )
      response.should redirect_to aspects_manage_path
    end

    it 'should redirect to the page which you called it from ' do
      pending "This controller should probably redirect to :back"
      put(:create, {
        :destination_handle => "johndoe@notadiasporaserver.com",
        :aspect_id => @user.aspects[0].id 
        } 
      )
      response.should redirect_to(:back)
    end
  end
end
