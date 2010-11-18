#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe RequestsController do
  render_views
  before do
    @user = make_user

    sign_in :user, @user
    request.env["HTTP_REFERER"] = "http://test.host"
    
    @user.aspects.create!(:name => "lame-os")
    @user.reload
  end
  
  describe '#destroy' do
    before do
      @other_user = make_user
      @other_user.aspects.create!(:name => "meh")
      @other_user.reload
      
      @other_user.send_contact_request_to(@user.person, @other_user.aspects.first)
      @user.reload # so it can find its pending requests.
      @friend_request = @user.pending_requests.first
    end
    describe 'when accepting a contact request' do
      it "succeeds" do
        xhr :delete, :destroy, "accept" => "true", "aspect_id" => @user.aspects.first.id.to_s, "id" => @friend_request.id.to_s
        response.should redirect_to(aspect_path(@user.aspects.first))
      end
    end
    describe 'when ignoring a contact request' do
      it "succeeds" do
        xhr :delete, :destroy, "id" => @friend_request.id.to_s
        response.should be_success
      end
      it "removes the request object" do
        lambda { 
          xhr :delete, :destroy, "id" => @friend_request.id.to_s
          }.should change(Request, 'count').by(-1)
      end
    end
  end

  describe '#create' do
    it "redirects when requesting to be contacts with yourself" do
      post(:create, :request => {
        :to => @user.diaspora_handle,
        :into => @user.aspects[0].id 
        } 
      )
      response.should redirect_to :back
    end
  
    it "flashes and redirects when requesting an invalid identity" do
      post(:create, :request => {
        :to => "not_a_@valid_email",
        :into => @user.aspects[0].id 
        }
      )
      flash[:error].should_not be_blank
      response.should redirect_to :back
    end
  
    it "flashes and redirects when requesting an invalid identity with a port number" do
      post(:create, :request => {
        :to => "johndoe@email.com:3000",
        :into => @user.aspects[0].id 
        } 
      )
      flash[:error].should_not be_blank
      response.should redirect_to :back
    end
  
    it "redirects when requesting an identity from an invalid server" do
      post(:create, :request => {
        :to => "johndoe@notadiasporaserver.com",
        :into => @user.aspects[0].id 
        } 
      )
      response.should redirect_to :back
    end
  end
end
