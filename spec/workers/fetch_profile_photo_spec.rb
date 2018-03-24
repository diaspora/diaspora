# frozen_string_literal: true

describe Workers::FetchProfilePhoto do
  before do
   @user = alice
   @service = FactoryGirl.build(:service, :user => alice)

   @url = "https://service.com/user/profile_image"

   allow(@service).to receive(:profile_photo_url).and_return(@url)
   allow(@user).to receive(:update_profile)

   allow(User).to receive(:find).and_return(@user)
   allow(Service).to receive(:find).and_return(@service)

    @photo_double = double
    allow(@photo_double).to receive(:save!).and_return(true)
    allow(@photo_double).to receive(:url).and_return("image.jpg")
  end

  it 'saves the profile image' do
    expect(@photo_double).to receive(:save!).and_return(true)
    expect(Photo).to receive(:diaspora_initialize).with(hash_including(:author => @user.person, :image_url => @url, :pending => true)).and_return(@photo_double)

    Workers::FetchProfilePhoto.new.perform(@user.id, @service.id)
  end

  context "service does not have a profile_photo_url" do
    it "does nothing without fallback" do
      allow(@service).to receive(:profile_photo_url).and_return(nil)
      expect(Photo).not_to receive(:diaspora_initialize)

      Workers::FetchProfilePhoto.new.perform(@user.id, @service.id)
    end

    it "fetches fallback if it's provided" do
      expect(@photo_double).to receive(:save!).and_return(true)
      allow(@service).to receive(:profile_photo_url).and_return(nil)
      expect(Photo).to receive(:diaspora_initialize).with(hash_including(:author => @user.person, :image_url => "https://service.com/fallback_lowres.jpg", :pending => true)).and_return(@photo_double)

      Workers::FetchProfilePhoto.new.perform(@user.id, @service.id, "https://service.com/fallback_lowres.jpg")
    end
  end


  it 'updates the profile' do
    allow(@photo_double).to receive(:url).and_return("large.jpg", "medium.jpg", "small.jpg")

    expect(Photo).to receive(:diaspora_initialize).and_return(@photo_double)
    expect(@user).to receive(:update_profile).with(hash_including({
                                               :image_url => "large.jpg",
                                               :image_url_medium => "medium.jpg",
                                               :image_url_small  => "small.jpg"
                                            }))

    Workers::FetchProfilePhoto.new.perform(@user.id, @service.id)
  end
end
