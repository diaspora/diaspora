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

include Diaspora

describe Diaspora do

  describe Webhooks do
    before do
      @user   = Factory.create(:user)
      @aspect  = @user.aspect(:name => "losers")
      @user2   = Factory.create(:user)
      @aspect2  = @user2.aspect(:name => "losers")
      friend_users(@user, @aspect, @user2, @aspect2)
    end

    describe "body" do
      before do
        @post = Factory.build(:status_message, :person => @user.person)
      end

      it "should add the following methods to Post on inclusion" do
        @post.respond_to?(:to_diaspora_xml).should be true
      end

    end
  end
end
