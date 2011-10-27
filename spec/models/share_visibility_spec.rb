#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe ShareVisibility do
  describe '.batch_import' do
    before do
      @post = Factory(:status_message, :author => alice.person)
      @contact = bob.contact_for(alice.person)
    end

    it 'creates a visibility for each user' do
      lambda {
        ShareVisibility.batch_import([@contact.id], @post)
      }.should change {
        ShareVisibility.exists?(:contact_id => @contact.id, :shareable_id => @post.id, :shareable_type => 'Post')
      }.from(false).to(true)
    end

    it 'does not raise if a visibility already exists' do
      ShareVisibility.create!(:contact_id => @contact.id, :shareable_id => @post.id, :shareable_type => 'Post')
      lambda {
        ShareVisibility.batch_import([@contact.id], @post)
      }.should_not raise_error
    end
  end
end
