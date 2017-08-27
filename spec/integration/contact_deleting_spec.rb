# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

describe 'disconnecting a contact', :type => :request do
  it 'removes the aspect membership' do
    @user = alice
    @user2 = bob

    expect{
      @user.disconnect(@user.contact_for(@user2.person))
    }.to change(AspectMembership, :count).by(-1)
  end
end
