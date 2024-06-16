# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

def with_carrierwave_processing(&block)
  UnprocessedImage.enable_processing = true
  yield
ensure
  UnprocessedImage.enable_processing = false
end

describe Photo, :type => :model do
  before do
    @user = alice
    @aspect = @user.aspects.first

    @fixture_filename  = 'button.png'

    @fixture_name      = File.join(File.dirname(__FILE__), '..', 'fixtures', @fixture_filename)
    @fail_fixture_name = File.join(File.dirname(__FILE__), '..', 'fixtures', 'msg.xml')

    @photo = @user.build_post(:photo, user_file: File.open(@fixture_name), to: @aspect.id)
    @photo2 = @user.build_post(:photo, user_file: File.open(@fixture_name), to: @aspect.id)
    @saved_photo = @user.build_post(:photo, user_file: File.open(@fixture_name), to: @aspect.id)
    @saved_photo.save
  end

  describe 'after_create' do
    it 'calls #queue_processing_job' do
      expect(@photo).to receive(:queue_processing_job)

      @photo.save!
    end
  end

  it 'has a random string key' do
    expect(@photo2.random_string).not_to be nil
  end

  describe '#diaspora_initialize' do
    before do
      @image = File.open(@fixture_name)
      @photo = Photo.diaspora_initialize(author: @user.person, user_file: @image)
    end

    it 'sets the persons diaspora handle' do
      expect(@photo.diaspora_handle).to eq(@user.person.diaspora_handle)
    end

    it 'sets the random prefix' do
      photo_double = double.as_null_object
      expect(photo_double).to receive(:random_string=)
      allow(Photo).to receive(:new).and_return(photo_double)

      Photo.diaspora_initialize(
        :author => @user.person, :user_file => @image)
    end

    context "with user file" do
      it 'builds the photo without saving' do
        expect(@photo.created_at.nil?).to be true
        expect(@photo.unprocessed_image.read.nil?).to be false
      end
    end

    context "with a url" do
      it 'saves the photo' do
        url = "https://service.com/user/profile_image"

        photo_double = double.as_null_object
        expect(photo_double).to receive(:remote_unprocessed_image_url=).with(url)
        allow(Photo).to receive(:new).and_return(photo_double)

        Photo.diaspora_initialize(
                :author => @user.person, :image_url => url)
      end
    end
  end

  describe '#update_remote_path' do
    before do
      image = File.open(@fixture_name)
      @photo = Photo.diaspora_initialize(
                :author => @user.person, :user_file => image)
      @photo.processed_image.store!(@photo.unprocessed_image)
      @photo.save!
    end
    it 'sets a remote url' do
      @photo.update_remote_path

      expect(@photo.remote_photo_path).to include("http")
      expect(@photo.remote_photo_name).to include(".webp")
    end
  end

  it 'should save a photo' do
    @photo.unprocessed_image.store! File.open(@fixture_name)
    expect(@photo.save).to eq(true)

    binary = @photo.unprocessed_image.read.force_encoding('BINARY')
    fixture_binary = File.read(@fixture_name).force_encoding('BINARY')

    expect(binary).to eq(fixture_binary)
  end

  context 'with a saved photo' do
    before do
      with_carrierwave_processing do
        @photo.unprocessed_image.store! File.open(@fixture_name)
      end
    end

    it 'should have text' do
      @photo.text= "cool story, bro"
      expect(@photo.save).to be true
    end

    it 'should remove its reference in user profile if it is referred' do
      @photo.save

      @user.profile.image_url = @photo.url(:thumb_large)
      @user.person.save
      @photo.destroy
      expect(Person.find(@user.person.id).profile[:image_url]).to be_nil
    end

    it 'should not use the imported filename as the url' do
      expect(@photo.url).not_to include @fixture_filename
      expect(@photo.url(:thumb_medium)).not_to include ("/" + @fixture_filename)
    end

    it 'should save the image dimensions' do
      expect(@photo.width).to eq(40)
      expect(@photo.height).to eq(40)
    end
  end

  context 'with a saved photo containing EXIF data' do

    let(:base_path) { File.dirname(__FILE__) }
    let(:public_path) { File.join(base_path, "../../public/") }
    let(:photo_with_exif) { File.open(File.join(base_path, "..", "fixtures", "exif.jpg")) }

    after do
      FileUtils.rm_r Dir.glob(File.join(public_path, "uploads/images/*"))
    end

    it "should strip EXIF data" do
      image = image_from a_photo_sent_by(bob)

      expect(image.exif.length).to eq(0)
    end

    def a_photo_sent_by(user)
      photo = user.build_post(:photo, user_file: photo_with_exif, to: @aspect.id)

      with_carrierwave_processing do
        photo.unprocessed_image.store! photo_with_exif
        photo.save
      end

      photo
    end

    def image_from(photo)
      photo_path = File.join(public_path, photo.unprocessed_image.store_dir, photo.unprocessed_image.filename)
      MiniMagick::Image.new(photo_path)
    end
  end

  describe 'non-image files' do
    it 'should not store' do
      file = File.open(@fail_fixture_name)
      expect {
        @photo.unprocessed_image.store! file
      }.to raise_error CarrierWave::IntegrityError
    end
  end

  describe "converting files" do
    it "convert to webp" do
      with_carrierwave_processing do
        @photo.unprocessed_image.store! File.open(@fixture_name)
      end
      expect(@photo.remote_photo_name).to include(".webp")
    end
  end

  describe "remote photos" do
    it "should set the remote_photo on marshalling" do
      url = @saved_photo.url
      thumb_url = @saved_photo.url :thumb_medium

      @saved_photo.height = 42
      @saved_photo.width = 23

      federation_photo = Diaspora::Federation::Entities.photo(@saved_photo)

      @saved_photo.destroy

      Diaspora::Federation::Receive.perform(federation_photo)

      new_photo = Photo.find_by(guid: @saved_photo.guid)
      expect(new_photo.url).to eq(url)
      expect(new_photo.url(:thumb_medium)).to eq(thumb_url)
    end
  end

  describe '#queue_processing_job' do
    it 'should queue a job to process the images' do
      expect(Workers::ProcessPhoto).to receive(:perform_async).with(@photo.id)
      @photo.queue_processing_job
    end
  end

  context "deletion" do
    before do
      @status_message = @user.build_post(:status_message, :text => "", :to => @aspect.id)
      @status_message.photos << @photo2
      @status_message.save
      @status_message.reload
    end

    it 'is deleted with parent status message' do
      expect {
        @status_message.destroy
      }.to change(Photo, :count).by(-1)
    end

    it 'will delete parent status message if message is otherwise empty' do
      expect {
        @photo2.destroy
      }.to change(StatusMessage, :count).by(-1)
    end

    it 'will not delete parent status message if message had other content' do
      @status_message.text = "Some text"
      @status_message.save
      @status_message.reload

      expect {
        @photo2.status_message.reload
        @photo2.destroy
      }.to_not change(StatusMessage, :count)
    end
  end

  describe "#visible" do
    context "with a current user" do
      it "calls photos_from" do
        expect(@user).to receive(:photos_from).with(@user.person, limit: :all, max_time: nil).and_call_original
        Photo.visible(@user, @user.person)
      end

      it "does not contain pending photos" do
        pending_photo = @user.post(:photo, pending: true, user_file: File.open(photo_fixture_name), to: @aspect)
        expect(Photo.visible(@user, @user.person).ids).not_to include(pending_photo.id)
      end
    end

    context "without a current user" do
      it "returns all public photos" do
        expect(Photo).to receive(:where).with(author_id: @user.person.id, public: true).and_call_original
        Photo.visible(nil, @user.person)
      end
    end
  end

  context "with a maliciously crafted image" do
    let(:base_path) { File.dirname(__FILE__) }
    let(:public_path) { File.join(base_path, "../../public/") }
    let(:evil_image) { File.open(File.join(base_path, "..", "fixtures", "evil-image.ps.png")) }

    it "fails to process a PostScript file camouflaged as a PNG" do
      photo = bob.build_post(:photo, user_file: evil_image, to: @aspect.id)

      expect {
        with_carrierwave_processing do
          photo.unprocessed_image.store! evil_image
          photo.save
        end
      }.to raise_error(CarrierWave::ProcessingError)
    end
  end
end
