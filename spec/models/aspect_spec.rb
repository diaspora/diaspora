#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Aspect do
  describe 'creation' do
    before do
      @name = alice.aspects.first.name
    end

    it 'does not allow duplicate names' do
      lambda {
        invalid_aspect = alice.aspects.create(:name => @name)
      }.should_not change(Aspect, :count)
    end

    it 'validates case insensitiveness on names' do
      lambda {
        invalid_aspect = alice.aspects.create(:name => @name.titleize)
      }.should_not change(Aspect, :count)
    end

    it 'has a 20 character limit on names' do
      aspect = Aspect.new(:name => "this name is really too too too too too long")
      aspect.valid?.should == false
    end

    it 'is able to have other users as contacts' do
      aspect = alice.aspects.create(:name => 'losers')

      Contact.create(:user => alice, :person => eve.person, :aspects => [aspect])
      aspect.contacts.where(:person_id => alice.person.id).should be_empty
      aspect.contacts.where(:person_id => eve.person.id).should_not be_empty
      aspect.contacts.size.should == 1
    end

    it 'has a contacts_visible? method' do
      alice.aspects.first.contacts_visible?.should be_true
    end
  end

  describe 'validation' do
    it 'has no uniqueness of name between users' do
      aspect = alice.aspects.create(:name => "New Aspect")
      aspect2 = eve.aspects.create(:name => aspect.name)
      aspect2.should be_valid
    end
  end
end
