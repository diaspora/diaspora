# frozen_string_literal: true

describe PhotoService do
  before do
    alice_eve_spec = alice.aspects.create(name: "eve aspect")
    alice.share_with(eve.person, alice_eve_spec)
    alice_bob_spec = alice.aspects.create(name: "bob aspect")
    alice.share_with(bob.person, alice_bob_spec)
    @alice_eve_photo = alice.post(:photo, pending: false, user_file: File.open(photo_fixture_name),
                                 to: alice_eve_spec.id)
    @alice_bob_photo = alice.post(:photo, pending: false, user_file: File.open(photo_fixture_name),
                                 to: alice_bob_spec.id)
    @alice_public_photo = alice.post(:photo, pending: false, user_file: File.open(photo_fixture_name), public: true)
    @bob_photo1 = bob.post(:photo, pending: true, user_file: File.open(photo_fixture_name), public: true)
  end

  describe "visible_photo" do
    it "returns a user's photo" do
      photo = photo_service.visible_photo(@bob_photo1.guid)
      expect(photo.guid).to eq(@bob_photo1.guid)
    end

    it "returns another user's public photo" do
      photo = photo_service.visible_photo(@alice_public_photo.guid)
      expect(photo.guid).to eq(@alice_public_photo.guid)
    end

    it "returns another user's shared photo" do
      photo = photo_service.visible_photo(@alice_bob_photo.guid)
      expect(photo.guid).to eq(@alice_bob_photo.guid)
    end

    it "returns nil for other user's private photo" do
      photo = photo_service.visible_photo(@alice_eve_photo.guid)
      expect(photo).to be_nil
    end
  end

  describe "create" do
    before do
      @image_file = Rack::Test::UploadedFile.new(Rails.root.join("spec", "fixtures", "button.png").to_s, "image/png")
    end

    context "succeeds" do
      it "accepts a photo from a regular form uploaded file no parameters" do
        params = ActionController::Parameters.new
        photo = photo_service.create_from_params_and_file(params, @image_file)
        expect(photo).not_to be_nil
        expect(photo.pending?).to be_falsey
        expect(photo.public?).to be_falsey
      end

      it "honors pending" do
        params = ActionController::Parameters.new(pending: true)
        photo = photo_service.create_from_params_and_file(params, @image_file)
        expect(photo).not_to be_nil
        expect(photo.pending?).to be_truthy
        expect(photo.public?).to be_falsey
      end

      it "sets a user profile when requested" do
        original_profile_pic = bob.person.profile.image_url
        params = ActionController::Parameters.new(set_profile_photo: true)
        photo = photo_service.create_from_params_and_file(params, @image_file)
        expect(photo).not_to be_nil
        expect(bob.reload.person.profile.image_url).not_to eq(original_profile_pic)
      end

      it "has correct aspects settings for limited shared" do
        params = ActionController::Parameters.new(pending: false, aspect_ids: [bob.aspects.first.id])
        photo = photo_service.create_from_params_and_file(params, @image_file)
        expect(photo).not_to be_nil
        expect(photo.pending?).to be_falsey
        expect(photo.public?).to be_falsey
      end

      it "allow raw file if explicitly allowing" do
        params = ActionController::Parameters.new
        photo = photo_service(bob, false).create_from_params_and_file(params, uploaded_photo)
        expect(photo).not_to be_nil
      end
    end

    context "fails" do
      before do
        @params = ActionController::Parameters.new
      end

      it "fails if given a raw file" do
        expect {
          photo_service.create_from_params_and_file(@params, uploaded_photo)
        }.to raise_error RuntimeError
      end

      it "file type isn't an image" do
        text_file = Rack::Test::UploadedFile.new(Rails.root.join("README.md").to_s, "text/plain")
        expect {
          photo_service.create_from_params_and_file(@params, text_file)
        }.to raise_error CarrierWave::IntegrityError

        text_file = Rack::Test::UploadedFile.new(Rails.root.join("README.md").to_s, "image/png")
        expect {
          photo_service.create_from_params_and_file(@params, text_file)
        }.to raise_error CarrierWave::IntegrityError
      end
    end
  end

  def photo_service(user=bob, deny_raw_files=true)
    PhotoService.new(user, deny_raw_files)
  end
end
