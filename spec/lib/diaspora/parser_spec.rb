#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Diaspora::Parser do
  before do
    @user1 = alice
    @user2 = bob
    @user3 = eve

    @aspect1 = @user1.aspects.first
    @aspect2 = @user2.aspects.first
    @aspect3 = @user3.aspects.first

    @person = FactoryGirl.create(:person)
  end

  describe "parsing compliant XML object" do
    it 'should be able to correctly parse comment fields' do
      post = @user1.post :status_message, :text => "hello", :to => @aspect1.id
      comment = FactoryGirl.create(:comment, :post => post, :author => @person, :diaspora_handle => @person.diaspora_handle, :text => "Freedom!")
      comment.delete
      xml = comment.to_diaspora_xml
      comment_from_xml = Diaspora::Parser.from_xml(xml)
      expect(comment_from_xml.diaspora_handle).to eq(@person.diaspora_handle)
      expect(comment_from_xml.post).to eq(post)
      expect(comment_from_xml.text).to eq("Freedom!")
      expect(comment_from_xml).not_to be comment
    end
  end
end

