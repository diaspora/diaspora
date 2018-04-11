# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

describe AspectsController, :type => :controller do
  before do
    alice.getting_started = false
    alice.save
    sign_in alice, scope: :user
    @alices_aspect_1 = alice.aspects.where(:name => "generic").first
    @alices_aspect_2 = alice.aspects.create(:name => "another aspect")

    allow(@controller).to receive(:current_user).and_return(alice)
    request.env["HTTP_REFERER"] = 'http://' + request.host
  end

  describe "#show" do
    it "succeeds" do
      get :show, params: {id: @alices_aspect_1.id.to_s}
      expect(response).to be_redirect
    end
    it 'redirects on an invalid id' do
      get :show, params: {id: 0}
      expect(response).to be_redirect
    end
  end

  describe "#create" do
    context "with valid params" do
      it "creates an aspect" do
        expect(alice.aspects.count).to eq(2)
        post :create, params: {aspect: {name: "new aspect"}}
        expect(alice.reload.aspects.count).to eq(3)
      end

      it "returns the created aspect as json" do
        post :create, params: {aspect: {name: "new aspect"}}
        expect(JSON.parse(response.body)["id"]).to eq Aspect.find_by_name("new aspect").id
        expect(JSON.parse(response.body)["name"]).to eq "new aspect"
      end

      context "with person_id param" do
        it "creates a contact if one does not already exist" do
          expect {
            post :create, params: {person_id: eve.person.id, aspect: {name: "new"}}, format: :js
          }.to change {
            alice.contacts.count
          }.by(1)
        end

        it "adds a new contact to the new aspect" do
          post :create, params: {person_id: eve.person.id, aspect: {name: "new"}}, format: :js
          expect(alice.aspects.find_by_name("new").contacts.count).to eq(1)
        end

        it "adds an existing contact to the new aspect" do
          post :create, params: {person_id: bob.person.id, aspect: {name: "new"}}, format: :js
          expect(alice.aspects.find_by_name("new").contacts.count).to eq(1)
        end
      end
    end

    context "with invalid params" do
      it "does not create an aspect" do
        expect(alice.aspects.count).to eq(2)
        post :create, params: {aspect: {name: ""}}
        expect(alice.reload.aspects.count).to eq(2)
      end

      it "responds with 422" do
        post :create, params: {aspect: {name: ""}}
        expect(response.status).to eq(422)
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
      put :update, params: {id: @alices_aspect_1.id, aspect: params}
      expect(Aspect.find(@alices_aspect_1.id).user_id).to eq(alice.id)
    end

    it "should return the name and id of the updated item" do
      params = {"name" => "Bruisers"}
      put :update, params: {id: @alices_aspect_1.id, aspect: params}
      expect(response.body).to eq({ :id => @alices_aspect_1.id, :name => "Bruisers" }.to_json)
    end
  end

  describe "update_order" do
    it "updates the aspect order" do
      @alices_aspect_1.update_attributes(order_id: 10)
      @alices_aspect_2.update_attributes(order_id: 20)
      ordered_aspect_ids = [@alices_aspect_2.id, @alices_aspect_1.id]

      put :update_order, params: {ordered_aspect_ids: ordered_aspect_ids}

      expect(Aspect.find(@alices_aspect_1.id).order_id).to eq(1)
      expect(Aspect.find(@alices_aspect_2.id).order_id).to eq(0)
    end
  end

  describe "#destroy" do
    before do
      @alices_aspect_1 = alice.aspects.create(name: "Contacts")
    end

    context "with no auto follow back aspect" do
      it "destoys the aspect" do
        expect(alice.aspects.to_a).to include @alices_aspect_1
        post :destroy, params: {id: @alices_aspect_1.id}
        expect(alice.reload.aspects.to_a).not_to include @alices_aspect_1
      end

      it "renders a flash message on success" do
        post :destroy, params: {id: @alices_aspect_1.id}
        expect(flash[:notice]).to eq(I18n.t("aspects.destroy.success", name: @alices_aspect_1.name))
        expect(flash[:error]).to be_blank
      end
    end

    context "with the aspect set as auto follow back" do
      before do
        alice.auto_follow_back = true
        alice.auto_follow_back_aspect = @alices_aspect_1
        alice.save
      end

      it "destoys the aspect" do
        expect(alice.aspects.to_a).to include @alices_aspect_1
        post :destroy, params: {id: @alices_aspect_1.id}
        expect(alice.reload.aspects.to_a).not_to include @alices_aspect_1
      end

      it "disables auto follow back" do
        expect(alice.auto_follow_back).to be(true)
        expect(alice.auto_follow_back_aspect).to eq(@alices_aspect_1)
        post :destroy, params: {id: @alices_aspect_1.id}
        expect(alice.auto_follow_back).to be(false)
        expect(alice.auto_follow_back_aspect).to eq(nil)
      end

      it "renders a flash message telling you to set a new auto follow back aspect" do
        post :destroy, params: {id: @alices_aspect_1.id}
        expect(flash[:notice]).to eq(I18n.t("aspects.destroy.success_auto_follow_back", name: @alices_aspect_1.name))
        expect(flash[:error]).to be_blank
      end
    end
  end
end
