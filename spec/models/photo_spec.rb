#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Photo do
  before do
    @user = make_user
    @aspect = @user.aspects.create(:name => "losers")

    @fixture_filename  = 'button.png'
    @fixture_name      = File.join(File.dirname(__FILE__), '..', 'fixtures', @fixture_filename)
    @fail_fixture_name = File.join(File.dirname(__FILE__), '..', 'fixtures', 'msg.xml')

    @photo  = @user.post(:photo, :user_file=> File.open(@fixture_name), :to => @aspect.id)
    @photo2 = @user.post(:photo, :user_file=> File.open(@fixture_name), :to => @aspect.id)
  end

  describe "protected attributes" do
    it "doesn't allow mass assignment of person" do
      @photo.save!
      @photo.update_attributes(:person => Factory(:person))
      @photo.reload.person.should == @user.person
    end
    it "doesn't allow mass assignment of person_id" do
      @photo.save!
      @photo.update_attributes(:person_id => Factory(:person).id)
      @photo.reload.person.should == @user.person
    end
    it 'allows assignmant of caption' do
      @photo.save!
      @photo.update_attributes(:caption => "this is awesome!!")
      @photo.reload.caption.should == "this is awesome!!"
    end
  end

  it 'should be mutable' do
    @photo.mutable?.should == true   
  end

  it 'has a random string key' do
    @photo2.random_string.should_not be nil
  end

  describe '#instantiate' do
    it 'sets the persons diaspora handle' do
      @photo2.diaspora_handle.should == @user.person.diaspora_handle
    end
    it 'has a constructor' do
      image = File.open(@fixture_name)
      photo = Photo.instantiate(
                :person => @user.person, :user_file => image)
      photo.created_at.nil?.should be_true
      photo.image.read.nil?.should be_false
    end

  end

  it 'should save a photo' do
    @photo.image.store! File.open(@fixture_name)
    @photo.save.should == true
    begin
      binary = @photo.image.read.force_encoding('BINARY')
      fixture_binary = File.open(@fixture_name).read.force_encoding('BINARY')
    rescue NoMethodError # Ruby 1.8 doesn't have force_encoding
      binary = @photo.image.read
      fixture_binary = File.open(@fixture_name).read
    end
    binary.should == fixture_binary
  end

  context 'with a saved photo' do
    before do
      @photo.image.store! File.open(@fixture_name)
    end
    it 'should have a caption' do
      @photo.caption = "cool story, bro"
      @photo.save.should be_true
    end

    it 'should remove its reference in user profile if it is referred' do
      @photo.save

      @user.profile.image_url = @photo.image.url(:thumb_medium)
      @user.person.save
      @photo.destroy
      Person.find(@user.person.id).profile.image_url.should be_nil
    end

    it 'should not use the imported filename as the url' do
      @photo.image.url.include?(@fixture_filename).should be false
      @photo.image.url(:thumb_medium).include?("/" + @fixture_filename).should be false
    end
  end

  describe 'non-image files' do
    it 'should not store' do
      file = File.open(@fail_fixture_name)
      @photo.image.should_receive(:check_whitelist!)
      lambda {
        @photo.image.store! file
      }.should raise_error
    end

  end

  describe 'serialization' do
    before do
      @photo.image.store! File.open(@fixture_name)
      @xml = @photo.to_xml.to_s
    end
    it 'serializes the url' do
      @xml.include?(@photo.image.url).should be true
    end
    it 'serializes the diaspora_handle' do
      @xml.include?(@user.diaspora_handle).should be true
    end
  end
  describe 'remote photos' do
    it 'should set the remote_photo on marshalling' do
      @photo.image.store! File.open(@fixture_name)


      #security hax
      user2 = Factory.create(:user)
      aspect2 = user2.aspects.create(:name => "foobars")
      connect_users(@user, @aspect, user2, aspect2)

      url = @photo.url
      thumb_url = @photo.url :thumb_medium

      xml = @photo.to_diaspora_xml
      id = @photo.id

      @photo.destroy
      user2.receive xml, @user.person

      new_photo = Photo.first(:id => id)
      new_photo.url.nil?.should be false
      new_photo.url.include?(url).should be true
      new_photo.url(:thumb_medium).include?(thumb_url).should be true
    end
  end

  context "commenting" do

    it "forwards comments to parent status message" do
      pending 'IMPORTANT! comments need to get sent to parent status message for a photo if one is present.  do this from the photo model, NOT in comment.'
      status_message = @user.build_post(:status_message, :message => "whattup", :to => @aspect.id)
      status_message.photos << @photo2
      status_message.save
      proc{ @user.comment("big willy style", :on => @photo2) }.should change(status_message.comments, :count).by(1)
    end

    it "accepts comments if there is no parent status message" do
      proc{ @user.comment("big willy style", :on => @photo) }.should change(@photo.comments, :count).by(1)
    end
  end
end
