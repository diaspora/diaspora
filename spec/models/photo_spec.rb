#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Photo do
  before do
    @user = make_user
    @aspect = @user.aspects.create(:name => "losers")

    @fixture_filename = 'button.png'
    @fixture_name = File.join(File.dirname(__FILE__), '..', 'fixtures', @fixture_filename)
    @fail_fixture_name = File.join(File.dirname(__FILE__), '..', 'fixtures', 'msg.xml')

    @photo = Photo.new
    @photo.person = @user.person
    @photo.diaspora_handle = @user.person.diaspora_handle

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
  end

  it 'should be mutable' do
    @photo.mutable?.should == true   
  end

  describe '.instantiate' do
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

  it 'should have a caption' do
    @photo.image.store! File.open(@fixture_name)
    @photo.caption = "cool story, bro"
    @photo.save.should be_true
  end

  it 'should remove its reference in user profile if it is referred' do
    @photo.image.store! File.open(@fixture_name)
    @photo.save

    @user.profile.image_url = @photo.image.url(:thumb_medium)
    @user.save
    @user.person.save

    @user.profile.image_url.should == @photo.image.url(:thumb_medium)
    @photo.destroy
    @user.reload.profile.image_url.should be nil
  end

  it 'should not use the imported filename as the url' do
    @photo.image.store! File.open(@fixture_name)
    @photo.image.url.include?(@fixture_filename).should be false
    @photo.image.url(:thumb_medium).include?("/" + @fixture_filename).should be false
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
      friend_users(@user, @aspect, user2, aspect2)

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
end
