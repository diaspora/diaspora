#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Contact do
  describe 'validations' do
    let(:contact){Contact.new}
    
    it 'requires a user' do
      contact.valid?
      contact.errors.full_messages.should include "User can't be blank"
    end
    
    it 'requires a person' do
      contact.valid?
      contact.errors.full_messages.should include "Person can't be blank"
    end

    it 'has many aspects' do
      contact.associations[:aspects].type.should == :many
    end

    it 'has at least one aspect' do
      contact.valid?
      contact.errors.full_messages.should include "Aspects can't be blank"
    end

  end
end
