#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Photo do
  before do
    @user = Factory.create(:user)
    @aspect = @user.aspect(:name => "losers")
    @album = @user.post :album, :name => "foo", :to => @aspect.id

    @fixture_filename = 'button.png'
    @fixture_name = File.join(File.dirname(__FILE__), '..', 'fixtures', @fixture_filename)
    @fail_fixture_name = File.join(File.dirname(__FILE__), '..', 'fixtures', 'msg.xml')

    @photo = Photo.new(:person => @user.person, :album => @album)
  end

  it 'has a constructor' do
    image = File.open(@fixture_name)
    photo = Photo.instantiate(
              :person => @user.person, :album => @album, :user_file => image)
    photo.created_at.nil?.should be false
    photo.image.read.nil?.should be false
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

  it 'must have an album' do
    photo = Photo.new(:person => @user.person)
    photo.image = File.open(@fixture_name)
    photo.save
    photo.valid?.should be false
    photo.album = Album.create(:name => "foo", :person => @user.person)
    photo.save
    Photo.first.album.name.should == 'foo'
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

  describe 'remote photos' do
    it 'should write the url on serialization' do
      @photo.image = File.open(@fixture_name)
      @photo.image.store!
      @photo.save

      xml = @photo.to_xml.to_s

      xml.include?(@photo.image.url).should be true
    end

    it 'should have an album id on serialization' do
      @photo.image.store! File.open(@fixture_name)
      xml = @photo.to_xml.to_s
      xml.include?(@photo.album_id.to_s).should be true
    end

    it 'should set the remote_photo on marshalling' do
      @photo.image.store! File.open(@fixture_name)

      @photo.save
      @photo.reload

      url = @photo.url
      thumb_url = @photo.url :thumb_medium

      xml = @photo.to_diaspora_xml
      id = @photo.id

      @photo.destroy
      @user.receive xml, @photo.person

      new_photo = Photo.first(:id => id)
      new_photo.url.nil?.should be false
      new_photo.url.include?(url).should be true
      new_photo.url(:thumb_medium).include?(thumb_url).should be true
    end
  end
end
