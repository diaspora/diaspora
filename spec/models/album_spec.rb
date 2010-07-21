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

    photo =Photo.new(:person => @user)


    album.photos << photo
    album.photos.count.should == 1
  end



end
