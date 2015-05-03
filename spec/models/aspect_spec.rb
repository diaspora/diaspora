#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Aspect, :type => :model do
  describe 'creation' do
    before do
      @name = alice.aspects.first.name
    end

    it 'does not allow duplicate names' do
      expect {
        invalid_aspect = alice.aspects.create(:name => @name)
      }.not_to change(Aspect, :count)
    end

    it 'validates case insensitiveness on names' do
      expect {
        invalid_aspect = alice.aspects.create(:name => @name.titleize)
      }.not_to change(Aspect, :count)
    end

    it 'has a 20 character limit on names' do
      aspect = Aspect.new(:name => "this name is really too too too too too long")
      expect(aspect.valid?).to eq(false)
    end

    it 'is able to have other users as contacts' do
      aspect = alice.aspects.create(:name => 'losers')

      Contact.create(:user => alice, :person => eve.person, :aspects => [aspect])
      expect(aspect.contacts.where(:person_id => alice.person.id)).to be_empty
      expect(aspect.contacts.where(:person_id => eve.person.id)).not_to be_empty
      expect(aspect.contacts.size).to eq(1)
    end

    it 'has a contacts_visible? method' do
      expect(alice.aspects.first.contacts_visible?).to be true
    end
  end

  describe 'validation' do
    it 'has no uniqueness of name between users' do
      aspect = alice.aspects.create(:name => "New Aspect")
      aspect2 = eve.aspects.create(:name => aspect.name)
      expect(aspect2).to be_valid
    end
  end
end
