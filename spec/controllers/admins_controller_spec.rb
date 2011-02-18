require 'spec_helper'

describe AdminsController do
  render_views
  before do
    @user = Factory :user 
    sign_in :user, @user
  end

    it 'is behind redirect_unless_admin' do
      get :user_search
      response.should redirect_to root_url
    end

  context 'admin signed in' do
    before do
      AppConfig[:admins] = [@user.username]
    end

    describe '#user_search' do
      it 'succeeds' do
        get :user_search
        response.should be_success
      end

      it 'assings users to an empty array if nothing is searched for' do
        get :user_search
        assigns[:users].should == []
      end

      it 'should search on username' do
        get :user_search, :user => {:username => @user.username}
        assigns[:users].should == [@user]
      end

      it 'should search on email' do
        get :user_search, :user => {:email => @user.email}
        assigns[:users].should == [@user]
      end

      it 'should search on invitation_identifier' do
        @user.invitation_identifier = "La@foo.com"
        @user.save!
        get :user_search, :user => {:invitation_identifier => @user.invitation_identifier}
        assigns[:users].should == [@user]
      end

      it 'should search on invitation_token' do
        @user.invitation_token = "akjsdhflhasdf"
        @user.save
        get :user_search, :user => {:invitation_token => @user.invitation_token}
        assigns[:users].should == [@user]
      end
    end

    describe '#admin_inviter' do
      it 'invites a user' do
        Invitation.should_receive(:create_invitee).with(:identifier => 'bob@moms.com')
        get :admin_inviter, :identifier => 'bob@moms.com'
        response.should be_redirect
      end
    end
  end
end
