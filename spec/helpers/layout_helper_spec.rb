#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe LayoutHelper do
  before do
    @user = alice
  end

  describe "#page_title" do
    before do
      def current_user
        @current_user
      end
    end

    context "passed blank text" do
      it "returns Diaspora*" do
        page_title.should == "Diaspora*"
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