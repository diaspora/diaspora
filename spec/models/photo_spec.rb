require File.dirname(__FILE__) + '/../spec_helper'

describe Photo do
  before do
    @user = Factory.create(:user)
    @user.person.save

    @fixture_filename = 'bp.jpeg'
    @fixture_name = File.dirname(__FILE__) + '/../fixtures/bp.jpeg'
    @fail_fixture_name = File.dirname(__FILE__) + '/../fixtures/msg.xml'
    @album = Album.create(:name => "foo", :person => @user.person)
    @photo = Photo.new(:person => @user.person, :album => @album)
  end

  it 'should have a constructor' do
    image = File.open(@fixture_name)    
    photo = Photo.instantiate(:person => @user.person, :album => @album, :user_file => [image]) 
    photo.created_at.nil?.should be false
    photo.image.read.nil?.should be false
  end

  it 'should save a photo to GridFS' do
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
    pending "Until this passes, duplicate photos will cause errors"
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

    it 'should save a signed photo to GridFS' do
      photo  = @user.post(:photo, :album => @album, :user_file => [File.open(@fixture_name)])
      photo.save.should == true
      photo.verify_creator_signature.should be true
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
  end
end
