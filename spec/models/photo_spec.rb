require File.dirname(__FILE__) + '/../spec_helper'

describe Photo do
  before do
    @user = Factory.create(:user)
    @fixture_name = File.dirname(__FILE__) + '/../fixtures/bp.jpeg'
    @fail_fixture_name = File.dirname(__FILE__) + '/../fixtures/msg.xml'
    @photo = Photo.new(:person => @user, :album => Album.create(:name => "foo"))
  end
  it 'should save a @photo to GridFS' do
    file = File.open(@fixture_name)
    @photo.image = file
    @photo.save.should == true
    binary = @photo.image.read
    fixture_binary = File.open(@fixture_name).read
    binary.should == fixture_binary
  end
  describe 'non-image files' do
    it 'should not store' do
      file = File.open(@fail_fixture_name)
      @photo.image.should_receive(:check_whitelist!)
      lambda {
        @photo.image.store! file
      }.should raise_error
    end

    it 'should not save' do
      pending "We need to figure out the difference between us and the example app"
      file = File.open(@fail_fixture_name)
      @photo.image.should_receive(:check_whitelist!)
      @photo.image = file
      @photo.save.should == false
    end


    it  'must have an album' do
      photo = Photo.new(:person => @user)
      photo.valid?.should be false
      photo.album = Album.new(:name => "foo")
      photo.save
      Photo.first.album.name.should == 'foo'
    end
  end

  describe 'with encryption' do
    
    before do
      unstub_mocha_stubs
    end
    
    after do
      stub_signature_verification
    end

    it 'should save a signed @photo to GridFS' do
      @photo.image = File.open(@fixture_name)
      @photo.save.should == true
      @photo.verify_creator_signature.should be true
    end
    
  end

  describe 'remote photos' do
    it 'should write the url on serialization' do 
      @photo.image = File.open(@fixture_name)
      xml = @photo.to_xml.to_s
      xml.include?(@photo.image.path).should be true
      remote_photo = Photo.from_xml xml
      @photo.destroy
      remote_photo.image.read.nil?.should be false

    end
    it 'should have an album id on serialization' do
       @photo.image = File.open(@fixture_name)
      xml = @photo.to_xml.to_s
      xml.include?(@photo.album.id.to_s).should be true
      remote_photo = Photo.from_xml xml
      @photo.destroy
      remote_photo.save.should be true
      remote_photo.album.nil?.should be false
    end
  end
end
