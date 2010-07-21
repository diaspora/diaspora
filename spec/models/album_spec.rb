require File.dirname(__FILE__) + '/../spec_helper'

describe Album do
  before do
    @user = Factory.create(:user)
    @album = Album.new(:name => "test collection")
  end

  it 'should belong to a person' do
    person = Factory.create(:person)
    @album.person = person
    @album.valid?.should be true
    @album.save
    person.albums.count.should == 1
  end

  it 'should require a name' do
    @album.name = "test collection"
    @album.valid?.should be true

    @album.name = nil
    @album.valid?.should be false
  end

  it 'should contain photos' do
    album = Album.create(:name => "test collection")
    photo = Photo.new(:person => @user)

    album.photos << photo
    album.photos.count.should == 1
  end

  describe 'traversing' do
    before do
      @album = Album.create(:name => "test collection")
      @photo_one = Photo.create(:person => @user, :created_at => Time.now)
      @photo_two = Photo.create(:person => @user, :created_at => Time.now-1)
      @photo_three = Photo.create(:person => @user, :created_at => Time.now-2)

      @album.photos += [@photo_one, @photo_two, @photo_three]
    end

    it 'should retrieve the next photo relative to a given photo' do
      @album.next_photo(@photo_two).id.should == @photo_three.id
    end

    it 'should retrieve the previous photo relative to a given photo' do
      @album.prev_photo(@photo_two).id.should == @photo_one.id
    end

    describe 'wrapping' do
      it 'does next photo of last to first' do
        @album.next_photo(@photo_three).id.should == @photo_one.id
      end

      it 'does previous photo of first to last' do
        @album.prev_photo(@photo_one).id.should == @photo_three.id
      end
    end
  end



end
