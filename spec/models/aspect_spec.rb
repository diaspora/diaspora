#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Aspect do
  let(:user ) { alice }
  let(:connected_person) { Factory.create(:person) }
  let(:user2) { eve }
  let(:connected_person_2) { Factory.create(:person) }

  let(:aspect) {user.aspects.first }
  let(:aspect2) {user2.aspects.first }
  let(:aspect1) {user.aspects.create(:name => 'cats')}
  let(:user3) {Factory.create(:user)}
  let(:aspect3) {user3.aspects.create(:name => "lala")}

  describe 'creation' do
    let!(:aspect){user.aspects.create(:name => 'losers')}

    it 'does not allow duplicate names' do
      lambda {
        invalid_aspect = user.aspects.create(:name => "losers ")
      }.should_not change(Aspect, :count)
    end

    it 'validates case insensitiveness on names' do
      lambda {
        invalid_aspect = user.aspects.create(:name => "Losers ")
      }.should_not change(Aspect, :count)
    end

    it 'has a 20 character limit on names' do
      aspect = Aspect.new(:name => "this name is really too too too too too long")
      aspect.valid?.should == false
    end

    it 'is able to have other users as contacts' do
      Contact.create(:user => user, :person => user2.person, :aspects => [aspect])
      aspect.contacts.where(:person_id => user.person.id).should be_empty
      aspect.contacts.where(:person_id => user2.person.id).should_not be_empty
      aspect.contacts.size.should == 1
    end

    it 'has a contacts_visible? method' do
      aspect.contacts_visible?.should be_true
    end
  end

  describe 'validation' do
    it 'has a unique name for one user' do
      aspect2 = user.aspects.create(:name => aspect.name)
      aspect2.valid?.should be_false
    end

    it 'has no uniqueness between users' do
      aspect = user.aspects.create(:name => "New Aspect")
      aspect2 = user2.aspects.create(:name => aspect.name)
      aspect2.should be_valid
    end
  end
end
