#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Diaspora::Webhooks do
  it "should add the following methods to Post on inclusion" do
    user = Factory.build(:user)
    post = Factory.build(:status_message, :author => user.person)

    post.respond_to?(:to_diaspora_xml).should be true
  end
end
