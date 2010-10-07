#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe PublicsHelper do
  before do
    @user = Factory.create(:user)
    @person = Factory.create(:person)
  end

  it 'should be able to give me the terse url for webfinger' do
     @user.person.url = "http://example.com/"

      terse_url( @user.person.url ).should == 'example.com'
  end
end
