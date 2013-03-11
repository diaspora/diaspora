require 'spec_helper'

describe Service do

  before do
    @post = alice.post(:status_message, :text => "hello", :to => alice.aspects.first.id)
    @service = Services::Facebook.new(:access_token => "yeah", :uid => 1)
    alice.services << @service
  end

  it 'is unique to a user by service type and uid' do
    @service.save

    second_service = Services::Facebook.new(:access_token => "yeah", :uid => 1)

    alice.services << second_service
    alice.services.last.save
    alice.services.last.should be_invalid
  end

  it 'by default has no profile photo url' do
    Service.new.profile_photo_url.should be_nil
  end
  
  it 'removes text formatting markdown from post text' do
    service = Service.new
    message = "Text with some **bolded** and _italic_ parts."
    post = stub(:text => message)
    service.public_message(post, 200, '', false).should match "Text with some bolded and italic parts."
  end
  
  it 'keeps markdown in post text when specified' do
    service = Service.new
    message = "Text with some **bolded** and _italic_ parts."
    post = stub(:text => message)
    service.public_message(post, 200, '', false, true).should match 'Text with some \*\*bolded\*\* and _italic_ parts.'
  end
end
