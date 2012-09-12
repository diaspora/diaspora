require 'spec_helper'

describe Jobs::FetchProfilePhoto do
  before do
   @user = alice
   @service = FactoryGirl.build(:service, :user => alice)

   @url = "https://service.com/user/profile_image"

   @service.stub(:profile_photo_url).and_return(@url)
   @user.stub(:update_profile)

   User.stub(:find).and_return(@user)
   Service.stub(:find).and_return(@service)

    @photo_stub = stub
    @photo_stub.stub(:save!).and_return(true)
    @photo_stub.stub(:url).and_return("image.jpg")
  end

  it 'saves the profile image' do
    @photo_stub.should_receive(:save!).and_return(true)
    Photo.should_receive(:diaspora_initialize).with(hash_including(:author => @user.person, :image_url => @url, :pending => true)).and_return(@photo_stub)

    Jobs::FetchProfilePhoto.perform(@user.id, @service.id)
  end

  context "service does not have a profile_photo_url" do
    it "does nothing without fallback" do
      @service.stub!(:profile_photo_url).and_return(nil)
      Photo.should_not_receive(:diaspora_initialize)

      Jobs::FetchProfilePhoto.perform(@user.id, @service.id)
    end

    it "fetches fallback if it's provided" do
      @photo_stub.should_receive(:save!).and_return(true)
      @service.stub!(:profile_photo_url).and_return(nil)
      Photo.should_receive(:diaspora_initialize).with(hash_including(:author => @user.person, :image_url => "https://service.com/fallback_lowres.jpg", :pending => true)).and_return(@photo_stub)

      Jobs::FetchProfilePhoto.perform(@user.id, @service.id, "https://service.com/fallback_lowres.jpg")
    end
  end


  it 'updates the profile' do 
    @photo_stub.stub(:url).and_return("large.jpg", "medium.jpg", "small.jpg")

    Photo.should_receive(:diaspora_initialize).and_return(@photo_stub)
    @user.should_receive(:update_profile).with(hash_including({
                                               :image_url => "large.jpg",
                                               :image_url_medium => "medium.jpg",
                                               :image_url_small  => "small.jpg"
                                            }))

    Jobs::FetchProfilePhoto.perform(@user.id, @service.id)
  end
end
