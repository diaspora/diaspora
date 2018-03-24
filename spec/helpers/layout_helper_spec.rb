# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

describe LayoutHelper, :type => :helper do
  describe "#page_title" do
    context "passed blank text" do
      it "returns Diaspora*" do
        expect(page_title.to_s).to eq(pod_name)
      end
    end

    context "passed text" do
      it "returns the text" do
        text = "This is the title"
        expect(page_title(text)).to eq(text)
      end
    end
  end
end
