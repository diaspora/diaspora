#    Copyright 2010 Diaspora Inc.
#
#    This file is part of Diaspora.
#
#    Diaspora is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    Diaspora is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with Diaspora.  If not, see <http://www.gnu.org/licenses/>.
#



require File.dirname(__FILE__) + '/../spec_helper'

describe Photo do
  before do
    @user = Factory.create(:user)
    @aspect = @user.aspect(:name => "losers")
    @album = @user.post :album, :name => "foo", :to => @aspect.id

    @fixture_filename = 'button.png'
    @fixture_name = File.dirname(__FILE__) + '/../fixtures/button.png'
    @fail_fixture_name = File.dirname(__FILE__) + '/../fixtures/msg.xml'


    @photo = Photo.new(:person => @user.person, :album => @album)
  end

  it 'should have a constructor' do
    pending "Figure out how to make the photo posting api work in specs, it needs a file type"
    image = File.open(@fixture_name) 
    photo = Photo.instantiate(:person => @user.person, :album => @album, :user_file => [image]) 
    photo.created_at.nil?.should be false
    photo.image.read.nil?.should be false
  end

  it 'should save a photo' do
    @photo.image.store! File.open(@fixture_name)
    @photo.save.should == true
    binary = @photo.image.read
    fixture_binary = File.open(@fixture_name).read
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
    @photo.save
    Photo.first.caption.should == "cool story, bro"
  end

  it 'should remove its reference in user profile if it is referred' do
    @photo.image.store! File.open(@fixture_name)
    @photo.save

    @user.profile.image_url = @photo.image.url(:thumb_medium)
    @user.save
    @user.person.save

    User.first.profile.image_url.should == @photo.image.url(:thumb_medium)
    @photo.destroy
    User.first.profile.image_url.should be nil
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
  
  describe 'with encryption' do
    
    before do
      unstub_mocha_stubs
    end
    
    after do
      stub_signature_verification
    end

    it 'should save a signed photo' do
      pending "Figure out how to make the photo posting api work in specs, it needs a file type"
      photo = @user.post(:photo, :album_id => @album.id, :user_file => [File.open(@fixture_name)])
      photo.save.should == true
      photo.signature_valid?.should be true
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
      @user.receive xml
      
      new_photo = Photo.first(:id => id)
      new_photo.url.nil?.should be false
      new_photo.url.include?(url).should be true
      new_photo.url(:thumb_medium).include?(thumb_url).should be true
    end
  end
end
