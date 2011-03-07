#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe 'disconnecting a contact' do
  it 'removes the aspect membership' do
    @user = alice
    @user2 = bob

    lambda{
      @user.disconnect(@user.contact_for(@user2.person))
    }.should change(AspectMembership, :count).by(-1)
  end
end
