#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

describe PhotosController, :type => :controller do
  before do
    @alices_photo = alice.post(:photo, :user_file => uploaded_photo, :to => alice.aspects.first.id, :public => false)
    @bobs_photo = bob.post(:photo, :user_file => uploaded_photo, :to => bob.aspects.first.id, :public => true)

    sign_in alice, scope: :user
    request.env["HTTP_REFERER"] = ''
  end

  describe '#create' do
    before do
      @params = {
        :photo => {:aspect_ids => "all"},
        :qqfile => Rack::Test::UploadedFile.new(
          Rails.root.join("spec", "fixtures", "button.png").to_s,
          "image/png"
        )
      }
    end

    it 'accepts a photo from a regular form submission' do
      expect {
        post :create, @params
      }.to change(Photo, :count).by(1)
    end

    it 'returns application/json when possible' do
      request.env['HTTP_ACCEPT'] = 'application/json'
      expect(post(:create, @params).headers['Content-Type']).to match 'application/json.*'
    end

    it 'returns text/html by default' do
      request.env['HTTP_ACCEPT'] = 'text/html,*/*'
      expect(post(:create, @params).headers['Content-Type']).to match 'text/html.*'
    end
  end

  describe '#create' do
    before do
      allow(@controller).to receive(:file_handler).and_return(uploaded_photo)
      @params = {:photo => {:user_file => uploaded_photo, :aspect_ids => "all"} }
    end

    it "creates a photo" do
      expect {
        post :create, @params
      }.to change(Photo, :count).by(1)
    end

    it "doesn't allow mass assignment of person" do
      new_user = FactoryGirl.create(:user)
      @params[:photo][:author] = new_user
      post :create, @params
      expect(Photo.last.author).to eq(alice.person)
    end

    it "doesn't allow mass assignment of person_id" do
      new_user = FactoryGirl.create(:user)
      @params[:photo][:author_id] = new_user.id
      post :create, @params
      expect(Photo.last.author).to eq(alice.person)
    end

    it 'can set the photo as the profile photo' do
      old_url = alice.person.profile.image_url
      @params[:photo][:set_profile_photo] = true
      post :create, @params
      expect(alice.reload.person.profile.image_url).not_to eq(old_url)
    end
  end

  describe '#index' do
    it "succeeds without any available pictures" do
      get :index, :person_id => FactoryGirl.create(:person).guid.to_s

      expect(response).to be_success
    end

    it "succeeds on mobile devices without any available pictures" do
      get :index, format: :mobile, person_id: FactoryGirl.create(:person).guid.to_s
      expect(response).to be_success
    end

    it "succeeds on mobile devices with available pictures" do
      get :index, format: :mobile, person_id: bob.person.guid.to_s
      expect(response).to be_success
    end

    it "displays the logged in user's pictures" do
      get :index, :person_id => alice.person.guid.to_s
      expect(assigns[:person]).to eq(alice.person)
      expect(assigns[:posts]).to eq([@alices_photo])
    end

    it "displays another person's pictures" do
      get :index, :person_id => bob.person.guid.to_s
      expect(assigns[:person]).to eq(bob.person)
      expect(assigns[:posts]).to eq([@bobs_photo])
    end

    it "displays the correct number of photos" do
      16.times do |i|
        eve.post(:photo, :user_file => uploaded_photo, :to => eve.aspects.first.id, :public => true)
      end
      get :index, :person_id => eve.person.to_param
      expect(response.body).to include ',"photos_count":16'

      eve.post(:photo, :user_file => uploaded_photo, :to => eve.aspects.first.id, :public => false)
      get :index, :person_id => eve.person.to_param
      expect(response.body).to include ',"photos_count":16' # eve is not sharing with alice
    end

    it "returns json when requested" do
      request.env['HTTP_ACCEPT'] = 'application/json'
      get :index, :person_id => alice.person.guid.to_s

      expect(response.headers['Content-Type']).to match 'application/json.*'
    end

    it 'displays by date of creation' do
      max_time = bob.photos.first.created_at - 1.day
      get :index, person_id: bob.person.guid.to_s,
                  max_time: max_time.to_i

      expect(assigns[:posts]).to be_empty
    end

    context "with no user signed in" do
      before do
        sign_out :user
        @person = bob.person
      end

      it "succeeds" do
        get :index, person_id: @person.to_param
        expect(response.status).to eq(200)
      end

      it "succeeds on the mobile site" do
        get :index, person_id: @person.to_param, format: :mobile
        expect(response).to be_success
      end

      it "forces to sign in if the person is remote" do
        p = FactoryGirl.create(:person)

        get :index, person_id: p.to_param
        expect(response).to be_redirect
        expect(response).to redirect_to new_user_session_path
      end

      it "displays the correct number of photos" do
        16.times do
          eve.post(:photo, user_file: uploaded_photo, to: eve.aspects.first.id, public: true)
        end
        get :index, person_id: eve.person.to_param
        expect(response.body).to include ',"photos_count":16'

        eve.post(:photo, user_file: uploaded_photo, to: eve.aspects.first.id, public: false)
        get :index, person_id: eve.person.to_param
        expect(response.body).to include ',"photos_count":16'
      end

      it "displays a person's pictures" do
        get :index, person_id: bob.person.guid.to_s
        expect(assigns[:person]).to eq(bob.person)
        expect(assigns[:posts]).to eq([@bobs_photo])
      end
    end
  end

  describe '#destroy' do
    it 'let a user delete his message' do
      delete :destroy, :id => @alices_photo.id
      expect(Photo.find_by_id(@alices_photo.id)).to be_nil
    end

    it 'will let you delete your profile picture' do
      xhr :get, :make_profile_photo, :photo_id => @alices_photo.id, :format => :js
      delete :destroy, :id => @alices_photo.id
      expect(Photo.find_by_id(@alices_photo.id)).to be_nil
    end

    it 'sends a retraction on delete' do
      allow(@controller).to receive(:current_user).and_return(alice)
      expect(alice).to receive(:retract).with(@alices_photo)
      delete :destroy, :id => @alices_photo.id
    end

    it 'will not let you destroy posts visible to you' do
      delete :destroy, :id => @bobs_photo.id
      expect(Photo.find_by_id(@bobs_photo.id)).to be_truthy
    end

    it 'will not let you destroy posts you do not own' do
      eves_photo = eve.post(:photo, :user_file => uploaded_photo, :to => eve.aspects.first.id, :public => true)
      delete :destroy, :id => eves_photo.id
      expect(Photo.find_by_id(eves_photo.id)).to be_truthy
    end
  end

  describe "#make_profile_photo" do
    it 'should return a 201 on a js success' do
      xhr :get, :make_profile_photo, :photo_id => @alices_photo.id, :format => 'js'
      expect(response.code).to eq("201")
    end

    it 'should return a 422 on failure' do
      get :make_profile_photo, :photo_id => @bobs_photo.id
      expect(response.code).to eq("422")
    end
  end

  describe "#show" do
    it 'should return 404 for nonexistent stuff on mobile devices' do
      expect {
        get :show, :person_id => bob.person.guid, :id => 772831, :format => 'mobile'
      }.to raise_error ActiveRecord::RecordNotFound
    end

    it 'should return 200 for existing stuff on mobile devices' do
      get :show, :person_id => alice.person.guid, :id => @alices_photo.id, :format => 'mobile'
      expect(response).to be_success
    end

    it "doesn't leak private photos to the public" do
      sign_out :user
      expect {
        get :show, :person_id => alice.person.guid, :id => @alices_photo.id, :format => 'mobile'
      }.to raise_error ActiveRecord::RecordNotFound
    end
  end

end
