#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe User do
  let(:user) { Factory(:user) }
  let(:aspect) { user.aspect(:name => 'heroes') }
  let(:user2) { Factory(:user) }
  let(:aspect2) { user2.aspect(:name => 'stuff') }
  let(:user3) { Factory(:user) }
  let(:aspect3) { user3.aspect(:name => 'stuff') }

  describe "validation" do

    describe "of passwords" do
      it "fails if password doesn't match confirmation" do
        user = Factory.build(:user, :password => "password", :password_confirmation => "nope")
        user.should_not be_valid
      end

      it "succeeds if password matches confirmation" do
        user = Factory.build(:user, :password => "password", :password_confirmation => "password")
        user.should be_valid
      end
    end

    describe "of username" do
      it "requires a username" do
        user = Factory.build(:user, :username => nil)
        user.should_not be_valid
      end

      it "requires a unique username" do
        duplicate_user = Factory.build(:user, :username => user.username)
        duplicate_user.should_not be_valid
      end

      it "downcases the username" do
        user = Factory.build(:user, :username => "ALLUPPERCASE")
        user.valid?
        user.username.should == "alluppercase"

        user = Factory.build(:user, :username => "someUPPERCASE")
        user.valid?
        user.username.should == "someuppercase"
      end

      it "strips leading and trailing whitespace" do
        user = Factory.build(:user, :username => "    janie    ")
        user.should be_valid
        user.username.should == "janie"
      end

      it "fails if there's whitespace in the middle" do
        user = Factory.build(:user, :username => "bobby tables")
        user.should_not be_valid
      end
    end

    describe "of email" do
      it "requires email address" do
        user = Factory.build(:user, :email => nil)
        user.should_not be_valid
      end

      it "requires a unique email address" do
        duplicate_user = Factory.build(:user, :email => user.email)
        duplicate_user.should_not be_valid
      end
    end
  end

  describe '#diaspora_handle' do
    it 'uses the pod config url to set the diaspora_handle' do
      user.diaspora_handle.should == user.username + "@" + APP_CONFIG[:terse_pod_url]
    end
  end

  context 'profiles' do
    it 'should be able to update their profile and send it to their friends' do
      updated_profile = {:profile => {
        :first_name => 'bob',
        :last_name => 'billytown',
        :image_url => "http://clown.com"}}

      user.update_profile(updated_profile).should be true
      user.profile.image_url.should == "http://clown.com"
    end
  end

  context 'aspects' do

    it 'should delete an empty aspect' do
      user.drop_aspect(aspect)
      user.aspects.include?(aspect).should == false
    end

    it 'should not delete an aspect with friends' do
      friend_users(user, aspect, user2, aspect2)
      aspect.reload
      proc { user.drop_aspect(aspect) }.should raise_error /Aspect not empty/
      user.aspects.include?(aspect).should == true
    end
  end

  context 'account removal' do
    before do
      friend_users(user, aspect, user2, aspect2)
      friend_users(user, aspect, user3, aspect3)
    end

    it 'should unfriend everyone' do
      user.should_receive(:unfriend_everyone)
      user.destroy
    end

    it 'should remove person' do
      user.should_receive(:remove_person)
      user.destroy
    end


    it 'should remove all aspects' do
      pending "this should use :dependant => :destroy on the many assoc...but that screws this test suite..."
      aspects = user.aspects
      user.destroy
      proc { aspects.reload }.should raise_error /does not exist/

    end


    describe '#remove_person' do
      it 'should remove the person object' do
        person = user.person
        user.destroy
        person.reload
        person.should be nil
      end

      it 'should remove the posts' do
        message = user.post(:status_message, :message => "hi", :to => aspect.id)
        user.reload
        user.destroy
        proc { message.reload }.should raise_error /does not exist/
      end
    end

    describe '#unfriend_everyone' do

      before do
        user3.delete
      end

      it 'should send retractions to remote poeple' do
        user.should_receive(:unfriend).once
        user.destroy
      end

      it 'should unfriend local people' do
        user2.friends.count.should be 1
        user.destroy
        user2.reload
        user2.friends.count.should be 0
      end
    end
  end

end
