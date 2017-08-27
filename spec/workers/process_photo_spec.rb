# frozen_string_literal: true

describe Workers::ProcessPhoto do
  before do
   @user = alice
   @aspect = @user.aspects.first

   @fixture_name = File.join(File.dirname(__FILE__), '..', 'fixtures', 'button.png')

   @saved_photo = @user.build_post(:photo, :user_file => File.open(@fixture_name), :to => @aspect.id)
   @saved_photo.save
  end

  it 'saves the processed image' do
    expect(@saved_photo.processed_image.path).to be_nil

    result = Workers::ProcessPhoto.new.perform(@saved_photo.id)

    @saved_photo.reload

    expect(@saved_photo.processed_image.path).not_to be_nil
    expect(result).to be true
  end

  context 'when trying to process a photo that has already been processed' do
    before do
      Workers::ProcessPhoto.new.perform(@saved_photo.id)
      @saved_photo.reload
    end

    it 'does not process the photo' do
      processed_image_path = @saved_photo.processed_image.path

      result = Workers::ProcessPhoto.new.perform(@saved_photo.id)

      @saved_photo.reload

      expect(@saved_photo.processed_image.path).to eq(processed_image_path)
      expect(result).to be false
    end
  end

  context 'when a gif is uploaded' do
    before do
      @fixture_name = File.join(File.dirname(__FILE__), '..', 'fixtures', 'button.gif')
      @saved_gif = @user.build_post(:photo, :user_file => File.open(@fixture_name), :to => @aspect.id)
      @saved_gif.save
    end

    it 'does not process the gif' do
      result = Workers::ProcessPhoto.new.perform(@saved_gif.id)

      expect(@saved_gif.reload.processed_image.path).to be_nil
      expect(result).to be false
    end
  end

  it 'does not throw an error if it is called on a remote photo' do
    p = FactoryGirl.create(:remote_photo)
    p.unprocessed_image = nil
    expect{
      result = Workers::ProcessPhoto.new.perform(p.id)
    }.to_not raise_error

  end

  it 'handles already deleted photos gracefully' do
    expect {
      Workers::ProcessPhoto.new.perform(0)
    }.to_not raise_error
  end
end
