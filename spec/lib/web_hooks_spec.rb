#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Diaspora::Webhooks do
  before do
    @user = Factory.build(:user)
    @post = Factory.build(:status_message, :person => @user.person)
  end

  it "should add the following methods to Post on inclusion" do
    @post.respond_to?(:to_diaspora_xml).should be true
  end
end
