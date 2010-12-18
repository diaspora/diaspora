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
    it 'shows a login link if no user is not logged in' do
      get :show
      response.body.should include("login")
    end

    it 'redirects to aspects index if user is logged in' do
      sign_in @user
      get :show
      response.should redirect_to aspects_path
    end
  end

  #This describe should apply to any controller class.  HomeController is just the simplest.
  describe 'log overriding in lib/log_overrider' do
    before do
      Rails.stub(:logger).and_return(FakeLogger.new)
    end
    context 'cross-stage' do
      before do
        pending "This might require patching Rails"
        get :show
        @lines = Rails.logger.infos
        @id = @lines[1].match(/r_id=(\w+)\s/).captures.first
      end
      it 'logs a unified id in a request' do
        id = @lines.first.match(/r_id=(\w+)\s/).captures.first
        @lines.each do |line|
          line.match(/r_id=(\w+)\s/).captures.first.should == @id
        end
      end
      it 'logs different ids in different requests' do
        get :show
        old_lines = Rails.logger.infos.select do |line|
          line.match(/r_id=(\w+)\s/).captures.first == @id
        end
        old_lines.length.should == Rails.logger.infos.length/2
      end
    end
    context 'starting' do
      before do
        pending "This code is never reached in tests, but it seems to work in actual requests"
        get :show
        @line = Rails.logger.infos.first
      end
      it 'logs it' do
        @line.should match /event=request_started/
      end
    end
    context 'rendering' do
      before do
        get :show, :lasers => 'green'
        @lines = Rails.logger.infos.select{|l| l.include?("event=render")}
      end
      it 'logs all renders' do
        @lines.length.should == 1
      end
      it 'logs layouts' do
        pending 'where is the template=home/show line?'
        home_line = @lines.detect{|t|
          t.include?("template=home/show.html.haml")}
        home_line.should match /layout=layouts\/application/
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
