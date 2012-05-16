require 'spec_helper'

describe Jobs::ProcessPhoto do
  before do
   @user = alice
   @aspect = @user.aspects.first

   @fixture_name = File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'button.png')

   @saved_photo = @user.build_post(:photo, :user_file => File.open(@fixture_name), :to => @aspect.id)
   @saved_photo.save
  end

  it 'saves the processed image' do
    @saved_photo.processed_image.path.should be_nil

    result = Jobs::ProcessPhoto.perform(@saved_photo.id)

    @saved_photo.reload

    @saved_photo.processed_image.path.should_not be_nil
    result.should be true
  end

  context 'when trying to process a photo that has already been processed' do
    before do
      Jobs::ProcessPhoto.perform(@saved_photo.id)
      @saved_photo.reload
    end

    it 'does not process the photo' do
      processed_image_path = @saved_photo.processed_image.path

      result = Jobs::ProcessPhoto.perform(@saved_photo.id)

      @saved_photo.reload

      @saved_photo.processed_image.path.should == processed_image_path
      result.should be false
    end
  end

  context 'when a gif is uploaded' do
    before do
      @fixture_name = File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'button.gif')
      @saved_gif = @user.build_post(:photo, :user_file => File.open(@fixture_name), :to => @aspect.id)
      @saved_gif.save
    end

    it 'does not process the gif' do
      result = Jobs::ProcessPhoto.perform(@saved_gif.id)

      @saved_gif.reload.processed_image.path.should be_nil
      result.should be false
    end
  end

  it 'does not throw an error if it is called on a remote photo' do
    p = FactoryGirl.create(:remote_photo)
    p.unprocessed_image = nil
    expect{
      result = Jobs::ProcessPhoto.perform(p.id)
    }.to_not raise_error
    
  end
end
