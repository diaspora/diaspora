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

describe Retraction do
    before do
      @user = Factory.create(:user)
      @person = Factory.create(:person)
      @aspect = @user.aspect(:name => "Bruisers")
      @user.activate_friend(@person, @aspect)
      @post = @user.post :status_message, :message => "Destroy!", :to => @aspect.id
    end
  describe 'serialization' do
    it 'should have a post id after serialization' do
      retraction = Retraction.for(@post)
      xml = retraction.to_xml.to_s
      xml.include?(@post.id.to_s).should == true
    end
  end
  describe 'dispatching' do
    it 'should dispatch a message on delete' do
      Factory.create(:person)
      User::QUEUE.should_receive :add_post_request
      @post.destroy
    end
  end
end
