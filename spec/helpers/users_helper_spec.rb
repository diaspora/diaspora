#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.
require 'spec_helper'

describe UsersHelper do
  describe '#first_name_or_username' do
    before do
      @user = alice
    end

    it 'should display the first name if it is set' do
      first_name_or_username(@user).should == @user.person.profile.first_name
    end

    it 'should display the username if the first name is empty' do
      @user.person.profile.first_name = ""
      first_name_or_username(@user).should == @user.username
    end
  end
end
