# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

describe ProfilesController, :type => :controller do
  before do
    sign_in eve, scope: :user
  end

  describe '#show' do
    let(:mock_person) { FactoryGirl.create(:user) }
    let(:mock_presenter) { double(:as_json => {:rock_star => "Jamie Cai"})}

    it "returns a post Presenter" do
      expect(Person).to receive(:find_by_guid!).with("12345").and_return(mock_person)
      expect(PersonPresenter).to receive(:new).with(mock_person, eve).and_return(mock_presenter)

      get :show, params: {id: 12_345}, format: :json
      expect(response.body).to eq({:rock_star => "Jamie Cai"}.to_json)
    end
  end

  describe '#edit' do
    it 'succeeds' do
      get :edit
      expect(response).to be_success
    end

    it 'sets the profile to the current users profile' do
      get :edit
      expect(assigns[:profile]).to eq(eve.person.profile)
    end

    it 'sets the aspect to "person_edit" ' do
      get :edit
      expect(assigns[:aspect]).to eq(:person_edit)
    end

    it 'sets the person to the current users person' do
      get :edit
      expect(assigns[:person]).to eq(eve.person)
    end
  end

  describe '#update' do
    it "sets the flash" do
      put :update, params: {
        profile: {
          image_url:  "",
          first_name: "Will",
          last_name:  "Smith"
        }
      }
      expect(flash[:notice]).not_to be_blank
    end

    it "sets nsfw" do
      expect(eve.person.reload.profile.nsfw).to eq(false)
      put :update, params: {profile: {id: eve.person.id, nsfw: "1"}}
      expect(eve.person.reload.profile.nsfw).to eq(true)
    end

    it "unsets nsfw" do
      eve.person.profile.nsfw = true
      eve.person.profile.save

      expect(eve.person.reload.profile.nsfw).to eq(true)
      put :update, params: {profile: {id: eve.person.id}}
      expect(eve.person.reload.profile.nsfw).to eq(false)
    end

    it 'sets tags' do
      params = { :id => eve.person.id,
                 :tags => '#apples #oranges',
                 :profile => {:tag_string => ''} }

      put :update, params: params
      expect(eve.person.reload.profile.tag_list.to_set).to eq(%w[apples oranges].to_set)
    end

    it 'sets plaintext tags' do
      params = { :id => eve.person.id,
                 :tags => ',#apples,#oranges,',
                 :profile => {:tag_string => '#pears'} }

      put :update, params: params
      expect(eve.person.reload.profile.tag_list.to_set).to eq(%w[apples oranges pears].to_set)
    end

    it 'sets plaintext tags without #' do
      params = { :id => eve.person.id,
                 :tags => ',#apples,#oranges,',
                 :profile => {:tag_string => 'bananas'} }

      put :update, params: params
      expect(eve.person.reload.profile.tag_list.to_set).to eq(%w[apples oranges bananas].to_set)
    end

    it 'sets valid birthday' do
      params = { :id => eve.person.id,
                 :profile => {
                   :date => {
                     :year => '2001',
                     :month => '02',
                     :day => '28' } } }

      put :update, params: params
      birthday = eve.person.reload.profile.birthday
      expect(birthday.year).to eq(2001)
      expect(birthday.month).to eq(2)
      expect(birthday.day).to eq(28)
    end

    it 'displays error for invalid birthday' do
      params = { :id => eve.person.id,
                 :profile => {
                   :date => {
                     :year => '2001',
                     :month => '02',
                     :day => '31' } } }

      put :update, params: params
      expect(flash[:error]).not_to be_blank
    end

    context 'with a profile photo set' do
      before do
        @params = { :id => eve.person.id,
                    :profile =>
                     {:image_url => "",
                      :last_name  => eve.person.profile.last_name,
                      :first_name => eve.person.profile.first_name }}

        eve.person.profile.image_url = "http://tom.joindiaspora.com/images/user/tom.jpg"
        eve.person.profile.save
      end

      it "doesn't overwrite the profile photo when an empty string is passed in" do
        image_url = eve.person.profile.image_url
        put :update, params: @params

        expect(Person.find(eve.person.id).profile.image_url).to eq(image_url)
      end
    end

    context 'mass assignment' do
      before do
        new_person = FactoryGirl.create(:person)
        @profile_params = {:profile =>{ :person_id => new_person.id,
                                    :diaspora_handle => 'abc@a.com'}}
      end

      it 'person_id' do
        person = eve.person
        profile = person.profile
        put :update, params: @profile_params
        expect(profile.reload.person_id).to eq(person.id)
      end

      it 'diaspora handle' do
        put :update, params: @profile_params
        expect(Person.find(eve.person.id).profile[:diaspora_handle]).not_to eq('abc@a.com')
      end
    end
  end
end
