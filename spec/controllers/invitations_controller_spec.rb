#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe InvitationsController do
  include Devise::TestHelpers

  render_views

  let!(:user)   { make_user }
  let!(:aspect) { user.aspects.create(:name => "WIN!!") }

  before do
    request.env["devise.mapping"] = Devise.mappings[:user]
  end


  describe "#create" do
    before do
      user.invites = 5

      sign_in :user, user
      @invite = {:invite_messages=>"test", :aspects=> aspect.id.to_s, :email=>"abc@example.com"}
      @controller.stub!(:current_user).and_return(user)
      request.env["HTTP_REFERER"]= 'http://test.host/cats/foo'
    end

    it 'invites the requested user' do
      user.should_receive(:invite_user).and_return(make_user)
      post :create, :user => @invite
    end

    it 'creates an invitation' do
      lambda {
        post :create, :user => @invite
      }.should change(Invitation, :count).by(1)
    end

    it 'creates an invited user with five invites' do
      lambda {
        post :create, :user => @invite
      }.should change(User, :count).by(1)
      User.find_by_email("abc@example.com").invites.should == 5
    end

    it 'handles a comma separated list of emails' do
      lambda {
        post :create, :user => @invite.merge(:email => "foofoofoofoo@example.com, mbs@gmail.com")
      }.should change(User, :count).by(2)
    end

    it 'displays a message that tells you how many invites were sent, and which REJECTED' do
      post :create, :user => @invite.merge(
                                :email => "mbs@gmail.com, foo@bar.com, foo.com, lala@foo, cool@bar.com")
      flash[:notice].should_not be_empty
      flash[:notice].should =~ /mbs@gmail\.com/
      flash[:notice].should =~ /foo@bar\.com/
      flash[:notice].should =~ /cool@bar\.com/

      flash[:error].should_not be_empty
      flash[:error].should =~ /foo\.com/
      flash[:error].should =~ /lala@foo/
    end

    it "doesn't invite anyone if the user has no invites" do
      user.invites = 0
      user.save!
      lambda {
        post :create, :user => @invite.merge(
                                :email => "mbs@gmail.com, foo@bar.com, foo.com, lala@foo, cool@bar.com")
      }.should_not change(User, :count)
    end

    it 'returns to the previous page on success' do
      post :create, :user => @invite
      response.should redirect_to("http://test.host/cats/foo")
    end
  end

  describe "#update" do
    before do
      user.invites = 5
      @invited_user = user.invite_user(:email => "a@a.com", :aspect_id => user.aspects.first.id)
      @accept_params = {:user=>
        {:password_confirmation =>"password",
         :username=>"josh",
         :password=>"password",
         :invitation_token => @invited_user.invitation_token}}

    end
    context 'success' do
      it 'creates user' do
        put :update, @accept_params
        User.find_by_username(@accept_params[:user][:username]).should_not be_nil
      end

      it 'seeds the aspects' do
        put :update, @accept_params
        User.find_by_username(@accept_params[:user][:username]).aspects.count.should == 2
      end

      it 'adds a pending request' do
        put :update, @accept_params
        User.find_by_username(@accept_params[:user][:username]).pending_requests.count.should == 1
      end
    end
    context 'failure' do
      before do
        @fail_params = @accept_params
        @fail_params[:user][:username] = user.username
      end
      it 'stays on the invitation accept form' do
        put :update, @fail_params
        response.location.include?(accept_user_invitation_path).should be_true
      end
      it 'keeps the invitation token' do
        put :update, @fail_params
        response.location.include?("invitation_token=#{@invited_user.invitation_token}").should be_true
      end
    end
  end
end

