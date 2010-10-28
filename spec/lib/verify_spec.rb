#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'
require File.join(Rails.root, 'lib/diaspora/importer')

describe Diaspora::Importer do

  let!(:user1) { Factory(:user) }
  let!(:user2) { Factory(:user) }
  let!(:user3) { Factory(:user) }

  let(:aspect1) { user1.aspect(:name => "Work")   }
  let(:aspect2) { user2.aspect(:name => "Family") }
  let(:aspect3) { user3.aspect(:name => "Pivots") }

  let!(:status_message1) { user1.post(:status_message, :message => "One", :public => true, :to => aspect1.id) }
  let!(:status_message2) { user1.post(:status_message, :message => "Two", :public => true, :to => aspect1.id) }
  let!(:status_message3) { user2.post(:status_message, :message => "Three", :public => false, :to => aspect2.id) }

  let(:importer) { Diaspora::Importer.new(Diaspora::Parsers::XML) }

  context 'serialized user' do
    describe '#verify_user' do
      it 'should return true for a new valid user' do
        new_user = Factory(:user)
        new_user.delete
        importer.verify_user(new_user).should be true
      end

      it 'should return false if vaild user already exists' do
        u = User.first
        lambda{ importer.verify_user(user1) }.should raise_error
      end
    end

    describe '#verify_person_for_user' do
      it 'should pass if keys match' do
        importer.verify_person_for_user(user1, user1.person).should be true
      end

      it 'should fail if private and public keys do not match' do
        person = Factory(:person)
        lambda{ importer.verify_person_for_user(user1, person) }.should raise_error
      end

      it 'should pass if the person does not exist' do 
        user = Factory.build(:user)
        importer.verify_person_for_user(user, user.person)
      end
    end

    describe 'verify contacts' do
      let(:contact1)     {Contact.new(:user => user1, :person => user2.person, :aspects => [aspect1])}
      let(:contact2)     {Contact.new(:user => user1, :person => user3.person, :aspects => [aspect2])}
      let(:contact3)     {Contact.new(:user => user1, :person => user3.person, :aspects => [aspect3])}
      let(:less_contacts) {[contact1]}
      let(:same_contacts) {[contact1, contact2]}
      let(:more_contacts) {[contact1, contact2, contact3]}

      let(:person_ids)    {[user2.person.id, user3.person.id]}


      it 'should be false if the number of the number of contacts is not equal to the number of imported people' do
        importer.verify_contacts(less_contacts, person_ids).should be false
        importer.verify_contacts(same_contacts, person_ids).should be true
        importer.verify_contacts(more_contacts, person_ids).should be false
      end
    end

    describe '#filter_posts' do
      it 'should make sure all found posts are owned by the user' do
        posts = [status_message1, status_message2]
        whitelist = importer.filter_posts(posts, user1.person)[:whitelist]

        whitelist.should have(2).posts
        whitelist.should include status_message1.id.to_s
        whitelist.should include status_message2.id.to_s
      end

      it 'should remove posts not owned by the user' do
        posts = [status_message1, status_message2, status_message3]
        whitelist = importer.filter_posts(posts, user1.person)[:whitelist]

        whitelist.should have(2).posts
        whitelist.should_not include status_message3.id
      end

      it 'should return a list of unknown posts' do
        posts = [status_message1, status_message2, Factory.build(:status_message)]
        unknown = importer.filter_posts(posts, user1.person)[:unknown]

        unknown.should have(1).post
      end

      it 'should generate a whitelist, unknown posts inclusive' do
        posts = [status_message1, status_message2, Factory.build(:status_message)]
        filters = importer.filter_posts(posts, user1.person)

        filters[:whitelist].should include filters[:unknown].keys.first
      end
    end

    describe '#clean_aspects' do 
      it 'should purge posts not in whitelist that are present in aspects' do
        whitelist = {status_message1.id.to_s => true, status_message2.id.to_s => true}

        aspect1.reload
        aspect1.post_ids << status_message3.id.to_s

        proc{ importer.clean_aspects([aspect1], whitelist) }.should change(aspect1.post_ids, :count).by(-1)
        aspect1.post_ids.should_not include status_message3.id 
      end
    end

    describe '#filter_people' do
      it 'should filter people who already exist in the database' do
        new_peep = Factory.build(:person)
        people = [user1.person, user2.person, new_peep]
        
        importer.filter_people(people).keys.should == [new_peep.id.to_s]
      end
    end
  end
end
