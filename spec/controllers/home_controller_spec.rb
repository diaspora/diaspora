#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe HomeController do
  render_views

  before do
    @user = make_user
    sign_in @user
    sign_out @user
  end

  describe '#show' do
    it 'should show a login link if no user is not logged in' do
      get :show 
      response.body.should include("log in")
    end

    it 'should redirect to aspects index if user is logged in' do
      sign_in @user
      get :show 
      response.should redirect_to aspects_path
    end
  end

  #This describe should apply to any controller class.  HomeController is just the simplest.
  describe 'logging' do
    before do
      logger = FakeLogger.new
      Rails.stub(:logger).and_return(FakeLogger.new)
    end

    context 'routing' do
      before do
        get :show, :lasers => 'green'
        @line = Rails.logger.infos.first
      end
      it 'logs the routing of a request' do
        @line.include?('event=request_routed').should be_true
      end
      it 'logs the controller' do
        @line.include?('controller=HomeController').should be_true
      end
      it 'logs the action' do
        @line.include?('action=show').should be_true
      end
      it 'logs params' do
        @line.include?("params='{\"lasers\"=>\"green\"}'").should be_true
      end
      it 'logs format' do
        @line.include?("format=html")
      end
    end
    context 'completion' do
      context 'ok' do
        before do
          get :show, :lasers => 'green'
          @line = Rails.logger.infos.last
        end
        it 'logs the completion of a request' do
          @line.include?('event=request_completed').should be_true
        end
        it 'logs an ok' do
          @line.include?('status=200').should be_true
        end
        it 'logs the controller' do
          @line.include?('controller=HomeController').should be_true
        end
        it 'logs the action' do
          @line.include?('action=show').should be_true
        end
        it 'logs params' do
          @line.include?("params='{\"lasers\"=>\"green\"}'").should be_true
        end
        it 'does not log the view rendering time addition' do
          @line.include?("(Views: ").should be_false
        end
      end
      context 'redirected' do
        before do
          sign_in @user
          get :show, :lasers => 'green'
          @line = Rails.logger.infos.last
        end
        it 'logs a redirect' do
          @line.include?('status=302').should be_true
        end
      end
    end
  end
  class FakeLogger
    attr_accessor :infos
    def initialize
      self.infos = []
    end
    def info line
      self.infos << line
    end
  end
end
