#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe LayoutHelper do
  include ApplicationHelper
  before do
    @user = alice
  end

  describe "#set_current_user_in_javascript" do
    it "doesn't allow xss" do
      user = FactoryGirl.create :user
      profile = user.profile
      profile.update_attribute(:first_name, "</script><script>alert(0);</script>");
      stub!(:user_signed_in?).and_return true
      stub!(:current_user).and_return user
      set_current_user_in_javascript.should_not be_empty
      set_current_user_in_javascript.should_not include(profile.first_name)
    end
  end

  describe "#page_title" do
    before do
      def current_user
        @current_user
      end
    end

    context "passed blank text" do
      it "returns Diaspora*" do
        page_title.should == pod_name
      end
    end

    context "passed text" do
      it "returns the text" do
        text = "This is the title"
        page_title(text).should == text
      end
    end
  end
end
