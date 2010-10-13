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


    describe '#verify_posts' do
      it 'should make sure all found posts are owned by the user' do
        1.should ==2
        
      end
      
    end

  end
end
