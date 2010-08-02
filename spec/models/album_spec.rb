require File.dirname(__FILE__) + '/../spec_helper'

describe Album do
  before do
    @fixture_name = File.dirname(__FILE__) + '/../fixtures/bp.jpeg'
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
      photos = []
      1.upto 3 do
        photo =   Photo.new(:person => @user, :album => @album, :created_at => Time.now)
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
        photo =   Photo.new(:person => @user, :album => @album, :created_at => Time.now + n)
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
