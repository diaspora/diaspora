#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe AspectsController, :type => :controller do
  before do
    alice.getting_started = false
    alice.save
    sign_in :user, alice
    @alices_aspect_1 = alice.aspects.where(:name => "generic").first
    @alices_aspect_2 = alice.aspects.create(:name => "another aspect")

    allow(@controller).to receive(:current_user).and_return(alice)
    request.env["HTTP_REFERER"] = 'http://' + request.host
  end


  describe "#new" do
    it "renders a remote form if remote is true" do
      get :new, "remote" => "true"
      expect(response).to be_success
      expect(response.body).to match(/#{Regexp.escape('data-remote="true"')}/)
    end
    it "renders a non-remote form if remote is false" do
      get :new, "remote" => "false"
      expect(response).to be_success
      expect(response.body).not_to match(/#{Regexp.escape('data-remote="true"')}/)
    end
    it "renders a non-remote form if remote is missing" do
      get :new
      expect(response).to be_success
      expect(response.body).not_to match(/#{Regexp.escape('data-remote="true"')}/)
    end
  end

  describe "#show" do
    it "succeeds" do
      get :show, 'id' => @alices_aspect_1.id.to_s
      expect(response).to be_redirect
    end
    it 'redirects on an invalid id' do
      get :show, 'id' => 4341029835
      expect(response).to be_redirect
    end
  end

  describe "#create" do
    context "with valid params" do
      it "creates an aspect" do
        expect(alice.aspects.count).to eq(2)
        post :create, "aspect" => {"name" => "new aspect"}
        expect(alice.reload.aspects.count).to eq(3)
      end
      it "redirects to the aspect's contact page" do
        post :create, "aspect" => {"name" => "new aspect"}
        expect(response).to redirect_to(contacts_path(:a_id => Aspect.find_by_name("new aspect").id))
      end

      context "with person_id param" do
        it "creates a contact if one does not already exist" do
          expect {
            post :create, :format => 'js', :aspect => {:name => "new", :person_id => eve.person.id}
          }.to change {
            alice.contacts.count
          }.by(1)
        end

        it "adds a new contact to the new aspect" do
          post :create, :format => 'js', :aspect => {:name => "new", :person_id => eve.person.id}
          expect(alice.aspects.find_by_name("new").contacts.count).to eq(1)
        end

        it "adds an existing contact to the new aspect" do
          post :create, :format => 'js', :aspect => {:name => "new", :person_id => bob.person.id}
          expect(alice.aspects.find_by_name("new").contacts.count).to eq(1)
        end
      end
    end

    context "with invalid params" do
      it "does not create an aspect" do
        expect(alice.aspects.count).to eq(2)
        post :create, "aspect" => {"name" => ""}
        expect(alice.reload.aspects.count).to eq(2)
      end
      it "goes back to the page you came from" do
        post :create, "aspect" => {"name" => ""}
        expect(response).to redirect_to(:back)
      end
    end
  end

  describe "#update" do
    before do
      @alices_aspect_1 = alice.aspects.create(:name => "Bruisers")
    end

    it "doesn't overwrite random attributes" do
      new_user = FactoryGirl.create :user
      params = {"name" => "Bruisers"}
      params[:user_id] = new_user.id
      put('update', :id => @alices_aspect_1.id, "aspect" => params)
      expect(Aspect.find(@alices_aspect_1.id).user_id).to eq(alice.id)
    end

    it "should return the name and id of the updated item" do
      params = {"name" => "Bruisers"}
      put('update', :id => @alices_aspect_1.id, "aspect" => params)
      expect(response.body).to eq({ :id => @alices_aspect_1.id, :name => "Bruisers" }.to_json)
    end
  end

  describe "#toggle_contact_visibility" do
    it 'sets contacts visible' do
      @alices_aspect_1.contacts_visible = false
      @alices_aspect_1.save

      xhr :get, :toggle_contact_visibility, :aspect_id => @alices_aspect_1.id
      expect(@alices_aspect_1.reload.contacts_visible).to be true
    end

    it 'sets contacts hidden' do
      @alices_aspect_1.contacts_visible = true
      @alices_aspect_1.save

      xhr :get, :toggle_contact_visibility, :aspect_id => @alices_aspect_1.id
      expect(@alices_aspect_1.reload.contacts_visible).to be false
    end
  end
end
