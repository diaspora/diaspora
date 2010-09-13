#    Copyright 2010 Diaspora Inc.
#
#    This file is part of Diaspora.
#
#    Diaspora is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    Diaspora is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with Diaspora.  If not, see <http://www.gnu.org/licenses/>.
#



require File.dirname(__FILE__) + '/../spec_helper'

class SocketsController
  def url_options
    {:host => ""}
  end
end

describe SocketsController do
  render_views  
  before do
    @user = Factory.create(:user)
    @controller = SocketsController.new
  end

  it 'should unstub the websockets' do
      Diaspora::WebSocket.initialize_channels
      @controller.class.should == SocketsController
  end
  
  describe 'actionhash' do
    before do
      @aspect = @user.aspect :name => "losers"
      @message = @user.post :status_message, :message => "post through user for victory", :to => @aspect.id
      @fixture_name = File.dirname(__FILE__) + '/../fixtures/button.png'
    end
    
    it 'should actionhash photos' do
      @album = @user.post(:album, :name => "Loser faces", :to => @aspect.id)
      photo  = @user.post(:photo, :album_id => @album.id, :user_file => [File.open(@fixture_name)])
      json = @controller.action_hash(@user.id, photo, :aspect_ids => @user.aspects_with_post(@album.id).map{|g| g.id})
      json.include?('photo').should be_true
    end

    it 'should actionhash posts' do
      json = @controller.action_hash(@user.id, @message)
      json.include?(@message.message).should be_true
      json.include?('status_message').should be_true
    end

    it 'should actionhash retractions' do
      retraction = Retraction.for @message
      json = @controller.action_hash(@user.id, retraction)
      json.include?('retraction').should be_true
      json.include?("html\":null").should be_true
    end
  end
end
