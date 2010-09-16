#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.



require File.dirname(__FILE__) + '/../spec_helper'

describe Album do
  before do
    @fixture_name = File.dirname(__FILE__) + '/../fixtures/button.png'
    @user = Factory.create(:user)
    @user.person.save
    @aspect = @user.aspect(:name => "Foo")
    @album = @user.post(:album, :name => "test collection", :to => @aspect.id)
  end

  it 'should require a name' do
    @album.name = "test collection"
    @album.valid?.should be true

    @album.name = nil
    @album.valid?.should be false
  end

  it 'should contain photos' do
    photo = Factory.build(:photo, :person => @user.person)

    @album.photos << photo
    @album.photos.count.should == 1
  end

  it 'should remove all photos on album delete' do
      photos = []
      1.upto 3 do
        photo =   Photo.new(:person => @user.person, :album => @album, :created_at => Time.now)
        photo.image.store! File.open @fixture_name
        photos << photo
      end
      @album.photos += photos

      Photo.all.count.should == 3
      @album.destroy
      Photo.all.count.should == 0
  end

  describe 'traversing' do
    before do
      @photos = []
      1.upto 3 do |n|
        photo =   Photo.new(:person => @user.person, :album => @album, :created_at => Time.now + n)
        photo.image.store! File.open @fixture_name
        @photos << photo
      end
      @album.photos += @photos
    end

    it 'should traverse the album correctly' do
      #should retrieve the next photo relative to a given photo
      @album.next_photo(@photos[1]).id.should == @photos[2].id

      #should retrieve the previous photo relative to a given photo
      @album.prev_photo(@photos[1]).id.should == @photos[0].id

      #wrapping
      #does next photo of last to first
      @album.next_photo(@photos[2]).id.should == @photos[0].id

      #does previous photo of first to last
      @album.prev_photo(@photos[0]).id.should == @photos[2].id
    end
  end

  describe 'serialization' do
    before do
      @xml = @album.to_xml.to_s
    end
    it 'should have a person' do
      @xml.include?(@album.person.id.to_s).should be true
    end
    it 'should have a name' do
      @xml.include?(@album.name).should be true
    end
    it 'should have an id' do
      @xml.include?(@album.id.to_s).should be true
    end
  end
end
