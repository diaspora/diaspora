#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Contact do
  describe 'aspect_memberships' do
    it 'deletes dependent aspect memberships' do
      lambda{
        alice.contact_for(bob.person).destroy
      }.should change(AspectMembership, :count).by(-1)
    end
  end

  context 'validations' do
    let(:contact){Contact.new}

    it 'requires a user' do
      contact.valid?
      contact.errors.full_messages.should include "User can't be blank"
    end

    it 'requires a person' do
      contact.valid?
      contact.errors.full_messages.should include "Person can't be blank"
    end

    it 'ensures user is not making a contact for himself' do
      contact.person = alice.person
      contact.user = alice

      contact.valid?
      contact.errors.full_messages.should include "Cannot create self-contact"
    end

    it 'validates uniqueness' do
      person = Factory(:person)

      contact2 = alice.contacts.create(:person=>person)
      contact2.should be_valid

      contact.user = alice
      contact.person = person
      contact.should_not be_valid
    end
  end

  context 'scope' do
    describe 'sharing' do
      it 'returns contacts with sharing true' do
        lambda {
          alice.contacts.create!(:sharing => true, :person => Factory(:person))
          alice.contacts.create!(:sharing => false, :person => Factory(:person))
        }.should change{
          Contact.sharing.count
        }.by(1)
      end
    end

    describe 'receiving' do
      it 'returns contacts with sharing true' do
        lambda {
          alice.contacts.create!(:receiving => true, :person => Factory(:person))
          alice.contacts.create!(:receiving => false, :person => Factory(:person))
        }.should change{
          Contact.receiving.count
        }.by(1)
      end
    end

    describe 'only_sharing' do
      it 'returns contacts with sharing true and receiving false' do
        lambda {
          alice.contacts.create!(:receiving => true, :sharing => true, :person => Factory(:person))
          alice.contacts.create!(:receiving => false, :sharing => true, :person => Factory(:person))
          alice.contacts.create!(:receiving => false, :sharing => true, :person => Factory(:person))
          alice.contacts.create!(:receiving => true, :sharing => false, :person => Factory(:person))
        }.should change{
          Contact.receiving.count
        }.by(2)
      end
    end
  end

  describe '#contacts' do
    before do
      @alice = alice
      @bob = bob
      @eve = eve
      @bob.aspects.create(:name => 'next')
      @bob.aspects(true)
      @people1 = []
      @people2 = []

      1.upto(5) do
        person = Factory(:person)
        @bob.contacts.create(:person => person, :aspects => [@bob.aspects.first])
        @people1 << person
      end
      1.upto(5) do
        person = Factory(:person)
        @bob.contacts.create(:person => person, :aspects => [@bob.aspects.last])
        @people2 << person
      end
    #eve <-> bob <-> alice
    end

    context 'on a contact for a local user' do
      before do
        @alice.reload
        @alice.aspects.reload
        @contact = @alice.contact_for(@bob.person)
      end

      it "returns the target local user's contacts that are in the same aspect" do
        @contact.contacts.map{|p| p.id}.should =~ [@eve.person].concat(@people1).map{|p| p.id}
      end

      it 'returns nothing if contacts_visible is false in that aspect' do
        asp = @bob.aspects.first
        asp.contacts_visible = false
        asp.save
        @contact.contacts.should == []
      end

      it 'returns no duplicate contacts' do
        [@alice, @eve].each {|c| @bob.add_contact_to_aspect(@bob.contact_for(c.person), @bob.aspects.last)}
        contact_ids = @contact.contacts.map{|p| p.id}
        contact_ids.uniq.should == contact_ids
      end
    end

    context 'on a contact for a remote user' do
      before do
        @contact = @bob.contact_for @people1.first
      end
      it 'returns an empty array' do
        @contact.contacts.should == []
      end
    end
  end

  context 'requesting' do
    before do
      @contact = Contact.new
      @user = Factory.create(:user)
      @person = Factory(:person)

      @contact.user = @user
      @contact.person = @person
    end

    describe '#generate_request' do
      it 'makes a request' do
        @contact.stub(:user).and_return(@user)
        request = @contact.generate_request

        request.sender.should == @user.person
        request.recipient.should == @person
      end
    end

    describe '#dispatch_request' do
      it 'pushes to people' do
        @contact.stub(:user).and_return(@user)
        m = mock()
        m.should_receive(:post)
        Postzord::Dispatch.should_receive(:new).and_return(m)
        @contact.dispatch_request
      end
    end
  end
end
