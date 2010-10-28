#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe User do
  let(:user) { Factory(:user) }
  let(:aspect) { user.aspect(:name => 'heroes') }
  let(:user2) { Factory(:user) }
  let(:aspect2) { user2.aspect(:name => 'stuff') }

  it 'should have a key' do
    user.encryption_key.should_not be nil
  end

  describe "validation" do
    describe "of associated person" do
      it "fails if person is not valid" do
        user = Factory.build(:user)
        user.should be_valid

        user.person.update_attribute(:serialized_public_key, nil)
        user.person.should_not be_valid
        user.should_not be_valid

        user.errors.full_messages.count.should == 1
        user.errors.full_messages.first.should =~ /serialized public key/i
      end
    end

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
      it "requires presence" do
        user = Factory.build(:user, :username => nil)
        user.should_not be_valid
      end

      it "requires uniqueness" do
        duplicate_user = Factory.build(:user, :username => user.username)
        duplicate_user.should_not be_valid
      end

      it "keeps the original case" do
        user = Factory.build(:user, :username => "WeIrDcAsE")
        user.should be_valid
        user.username.should == "WeIrDcAsE"
      end

      it "fails if the requested username is only different in case from an existing username" do
        duplicate_user = Factory.build(:user, :username => user.username.upcase)
        duplicate_user.should_not be_valid
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

      it 'can not contain non url safe characters' do
        user = Factory.build(:user, :username => "kittens;")
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

    describe "of language" do
      it "requires availability" do
        user = Factory.build(:user, :language => 'some invalid language')
        user.should_not be_valid
      end

      it "should save with current language if blank" do
        I18n.locale = :fr
        user = Factory(:user, :language => nil)
        user.language.should == 'fr'
      end
    end
  end

  describe ".build" do
    context 'with valid params' do
      before do
        params = {:username => "ohai",
                  :email => "ohai@example.com",
                  :password => "password",
                  :password_confirmation => "password",
                  :person => 
                    {:profile => 
                      {:first_name => "O", 
                       :last_name => "Hai"}
                    }
        }
        @user = User.build(params)
      end
      it "makes a valid user" do
        @user.should be_valid
        @user.persisted?.should be_false
        User.find_by_username("ohai").should be_nil
      end
      it 'saves successfully' do
        @user.save.should be_true
        User.find_by_username("ohai").should == @user
      end
    end
    describe "with invalid params" do
      before do
        @invalid_params = {
          :username => "ohai",
          :email => "ohai@example.com",
          :password => "password",
          :password_confirmation => "wrongpasswordz",
          :person => {:profile => {:first_name => "", :last_name => ""}}}
      end
      it "raises no error" do
        lambda { User.build(@invalid_params) }.should_not raise_error
      end
      it "does not save" do
        User.build(@invalid_params).save.should be_false
      end
    end
  end

  describe ".find_for_authentication" do
    it "preserves case" do
      User.find_for_authentication(:username => user.username).should == user
      User.find_for_authentication(:username => user.username.upcase).should be_nil
    end
  end

  describe '#diaspora_handle' do
    it 'uses the pod config url to set the diaspora_handle' do
      user.diaspora_handle.should == user.username + "@" + APP_CONFIG[:terse_pod_url]
    end
  end

  context 'profiles' do
    it 'should be able to update their profile and send it to their friends' do
      updated_profile = {
        :first_name => 'bob',
        :last_name => 'billytown',
        :image_url => "http://clown.com"}

      user.update_profile(updated_profile).should be true
      user.reload.profile.image_url.should == "http://clown.com"
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

  describe 'account removal' do
    it 'should unfriend everyone' do
      user.should_receive(:unfriend_everyone)
      user.destroy
    end

    it 'should remove person' do
      user.should_receive(:remove_person)
      user.destroy
    end

    it 'should remove all aspects' do
      aspect
      lambda {user.destroy}.should change{user.aspects.reload.count}.by(-1)
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

      it 'should send retractions to remote poeple' do
        user2.delete
        user.activate_friend(user2.person, aspect)

        user.should_receive(:unfriend).once
        user.destroy
      end

      it 'should unfriend local people' do
        friend_users(user, aspect, user2, aspect2)
        lambda {user.destroy}.should change{user2.reload.friends.count}.by(-1)
      end
    end
  end
end
