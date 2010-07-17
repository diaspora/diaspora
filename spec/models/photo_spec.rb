require File.dirname(__FILE__) + '/../spec_helper'

describe Photo do
  before do
    @user = Factory.create(:user)
  end
  it 'should save a photo to GridFS' do
    photo = Photo.new(:person => @user)
    fixture_name = File.dirname(__FILE__) + '/../fixtures/bp.jpeg'
    file = File.open(fixture_name)
    photo.image = file
    photo.save.should == true
    binary = photo.image.read
    fixture_binary = File.open(fixture_name).read
    binary.should == fixture_binary
  end

  it 'should create thumbnails' do
    pending('need to figure this out... tearing issue')
  end

end
