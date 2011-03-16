require 'spec_helper'

describe Job::ProcessPhoto do
  it 'calls post_process on an image uploader' do
    photo = mock()
    photo.should_receive(:image).and_return(photo)
    photo.should_receive(:post_process)
    Photo.should_receive(:find).with(1).and_return(photo)
    Job::ProcessPhoto.perform(1)
  end
end
