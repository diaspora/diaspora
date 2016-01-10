#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require "spec_helper"

describe Diaspora::Parser do
  describe "parsing compliant XML object" do
    it "should be able to correctly parse comment fields" do
      user = FactoryGirl.create(:user)

      post = alice.post :status_message, text: "hello", to: alice.aspects.first.id
      comment = FactoryGirl.build(
        :comment_entity,
        parent_guid: post.guid,
        author:      user.diaspora_handle,
        text:        "Freedom!"
      )
      xml = Diaspora::Federation.xml(comment).to_xml
      comment_from_xml = Diaspora::Parser.from_xml(xml)
      expect(comment_from_xml.diaspora_handle).to eq(user.diaspora_handle)
      expect(comment_from_xml.post).to eq(post)
      expect(comment_from_xml.text).to eq("Freedom!")
      expect(comment_from_xml).not_to be comment
    end
  end
end
