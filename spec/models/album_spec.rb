require File.dirname(__FILE__) + '/../spec_helper'

describe Album do
  before do
    @user = Factory.create(:user)
    @album = Album.new(:name => "test collection", :person => @user)
  end

  it 'should belong to a person' do
    @album.person = nil
    @album.valid?.should be false
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
    album = Album.create(:name => "test collection", :person => @user)
    photo = Factory.build(:photo, :person => @user)

    album.photos << photo
    album.photos.count.should == 1
  end

  it 'should remove all photos on album delete' do
      photo_one = Factory.create(:photo, :person => @user, :album => @album, :created_at => Time.now)
      photo_two = Factory.create(:photo, :person => @user, :album => @album, :created_at => Time.now-1)
      photo_three = Factory.create(:photo, :person => @user, :album => @album, :created_at => Time.now-2)

      @album.photos += [photo_one, photo_two, photo_three]

      Photo.all.count.should == 3
      @album.destroy
      Photo.all.count.should == 0
  end

  describe 'traversing' do
    before do
      @photo_one = Factory.create(:photo, :person => @user, :album => @album, :created_at => Time.now)
      @photo_two = Factory.create(:photo, :person => @user, :album => @album, :created_at => Time.now+1)
      @photo_three = Factory.create(:photo, :person => @user, :album => @album, :created_at => Time.now+2)

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
