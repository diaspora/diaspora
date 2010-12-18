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

    @other_user = make_user
    @other_user.aspects.create!(:name => "meh")
    @other_user.reload
  end

  describe '#destroy' do
    before do
      @other_user.send_contact_request_to(@user.person, @other_user.aspects.first)
      @friend_request = Request.to(@user.person).first
    end
    describe 'when accepting a contact request' do
      it "succeeds" do
        xhr :delete, :destroy,
          :accept    => "true",
          :aspect_id => @user.aspects.first.id.to_s,
          :id        => @friend_request.id.to_s
        response.should redirect_to(aspect_path(@user.aspects.first))
      end
    end
    describe 'when ignoring a contact request' do
      it "succeeds" do
        xhr :delete, :destroy,
          :id => @friend_request.id.to_s
        response.should be_success
      end
      it "removes the request object" do
        lambda {
          xhr :delete, :destroy,
            :id => @friend_request.id.to_s
        }.should change(Request, :count).by(-1)
      end
    end
  end

  describe '#create' do
    context 'valid new request' do
      before do
        @params = {:request => {
          :to => @other_user.diaspora_handle,
          :into => @user.aspects[0].id
        }}
      end
      it 'creates a contact' do
        @user.contact_for(@other_user).should be_nil
        lambda {
          post :create, @params
        }.should change(Contact,:count).by(1)
        new_contact = @user.reload.contact_for(@other_user.person)
        new_contact.should_not be_nil
        new_contact.should be_pending
      end
      it 'does not persist a Request' do
        lambda {
          post :create, @params
        }.should_not change(Request, :count)
      end
    end
    it 'autoaccepts and when sending a request to someone who sent me a request' do
      @other_user.send_contact_request_to(@user.person, @other_user.aspects[0])

      post(:create, :request => {
        :to => @other_user.diaspora_handle,
        :into => @user.aspects[0].id}
      )
      Request.to(@user).first.should be_nil
      @user.contact_for(@other_user.person).should be_true
      @user.aspects[0].contacts.all(:person_id => @other_user.person.id).should be_true
    end

    it "redirects when requesting to be contacts with yourself" do
      post(:create, :request => {
        :to => @user.diaspora_handle,
        :into => @user.aspects[0].id
        }
      )
      flash[:error].should_not be_blank
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

    it "accepts no port numbers" do
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
      flash[:error].should_not be_blank
      response.should redirect_to :back
    end
  end
end
