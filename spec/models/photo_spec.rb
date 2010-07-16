require File.dirname(__FILE__) + '/../spec_helper'

describe Photo do
  it 'should upload a photo to GridFS' do

    photo = Photo.new
    file = File.open('/spec/fixtures/bp.jpeg')
    photo.image = file
    photo.save.should == true

  end

end
