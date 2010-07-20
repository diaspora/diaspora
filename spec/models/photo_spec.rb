require File.dirname(__FILE__) + '/../spec_helper'

describe Photo do
  before do
    @user = Factory.create(:user)
    @fixture_name = File.dirname(__FILE__) + '/../fixtures/bp.jpeg'
    @fail_fixture_name = File.dirname(__FILE__) + '/../fixtures/msg.xml'

  end
  it 'should save a photo to GridFS' do
    photo = Photo.new(:person => @user)
    file = File.open(@fixture_name)
    photo.image = file
    photo.save.should == true
    binary = photo.image.read
    fixture_binary = File.open(@fixture_name).read
    binary.should == fixture_binary
  end

  it 'should not accept files of non-image types' do
    photo = Photo.new(:person => @user)
    file = File.open(@fail_fixture_name)
    photo.image = file
    photo.save.should == false

  end
  describe 'with encryption' do
    
    before do
      unstub_mocha_stubs
    end
    
    after do
      stub_signature_verification
    end

    it 'should save a signed photo to GridFS' do
      photo = Photo.new(:person => @user)
      photo.image = File.open(@fixture_name)
      photo.save.should == true
      photo.verify_creator_signature.should be true
    end
    
  end
end
