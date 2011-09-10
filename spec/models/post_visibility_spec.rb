#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe PostVisibility do
  describe '.batch_import' do
    before do
      @post = Factory(:status_message, :author => alice.person)
      @contact = bob.contact_for(alice.person)
    end

    it 'creates a visibility for each user' do
      lambda {
        PostVisibility.batch_import([@contact], @post)
      }.should change {
        PostVisibility.exists?(:contact_id => @contact.id, :post_id => @post.id)
      }.from(false).to(true)
    end

    it 'does not raise if a visibility already exists' do
      PostVisibility.create!(:contact_id => @contact.id, :post_id => @post.id)
      lambda {
        PostVisibility.batch_import([@contact], @post)
      }.should_not raise_error
    end
  end
end
