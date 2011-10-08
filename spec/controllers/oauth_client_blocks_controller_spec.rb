#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe OauthClientBlocksController do
  before do
    @user = alice
    @aspect = @user.aspects.first
    @aspect1 = @user.aspects.create(:name => 'Cool People')

    @app1 = Factory(:app)
    @app2 = Factory(:app)
    @app3 = Factory(:app)
    @user.application_blocks.create :client_id => @app2.id, :user_id => @user.id

    sign_in :user, @user
  end

  describe '#update' do
    it "updates the user's application blocks" do
      @user.blocking_oauth_client?(@app1.name).should == false
      @user.blocking_oauth_client?(@app2.name).should == true
      @user.blocking_oauth_client?(@app3.name).should == false

      put(
        :update,
        :id => -1,
        'application_blocks' => {
          @app1.id.to_s => '1',
          @app2.id.to_s => '0',
          @app3.id.to_s => '1',
        }
      )

      response.should redirect_to(authorizations_path)
      flash[:notice].should == 'Application blocks updated.'

      @user.reload
      @user.blocking_oauth_client?(@app1.name).should == true
      @user.blocking_oauth_client?(@app2.name).should == false
      @user.blocking_oauth_client?(@app3.name).should == true
    end

    context 'when another user exists' do
      before do
        @user2 = bob
      end

      it 'should not update the other user' do
        put(
          :update,
          :id => -1,
          'application_blocks' => {
            @app1.id.to_s => '1',
            @app2.id.to_s => '0',
            @app3.id.to_s => '1',
          }
        )
        response.should redirect_to(authorizations_path)
        flash[:notice].should == 'Application blocks updated.'

        @user2.reload
        @user2.blocking_oauth_client?(@app1.name).should == false
        @user2.blocking_oauth_client?(@app2.name).should == false
        @user2.blocking_oauth_client?(@app3.name).should == false
      end
    end

    it 'silently ignores invalid application ids' do
      @user.blocking_oauth_client?(@app1.name).should == false
      @user.blocking_oauth_client?(@app2.name).should == true
      @user.blocking_oauth_client?(@app3.name).should == false

      put(
        :update,
        :id => -1,
        'application_blocks' => {
          @app1.id.to_s => '1',
          (@app2.id + @app3.id).to_s => '1',
        }
      )

      response.should redirect_to(authorizations_path)
      flash[:notice].should == 'Application blocks updated.'

      @user.reload
      @user.blocking_oauth_client?(@app1.name).should == true
      @user.blocking_oauth_client?(@app2.name).should == true
      @user.blocking_oauth_client?(@app3.name).should == false
    end
  end
end

