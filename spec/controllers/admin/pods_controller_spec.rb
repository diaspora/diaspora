# frozen_string_literal: true

describe Admin::PodsController, type: :controller do
  before do
    @user = FactoryGirl.create :user
    Role.add_admin(@user.person)

    sign_in @user, scope: :user
  end

  describe "#index" do
    it "renders the pod list template" do
      get :index
      expect(response).to render_template("admins/pods")
      expect(response.body).to match(/id='pod-alerts'/im)
      expect(response.body).to match(/id='pod-list'/im)
    end

    it "contains the preloads" do
      get :index
      expect(response.body).to match(/uncheckedCount=/im)
      expect(response.body).to match(/errorCount=/im)
      expect(response.body).to match(/preloads.*"pods"\s?\:/im)
    end

    it "returns the json data" do
      3.times { FactoryGirl.create(:pod) }

      get :index, format: :json

      expect(response.body).to eql(PodPresenter.as_collection(Pod.all).to_json)
    end
  end

  describe "#recheck" do
    before do
      @pod = FactoryGirl.create(:pod).reload
      allow(Pod).to receive(:find) { @pod }
      expect(@pod).to receive(:test_connection!)
    end

    it "performs a connection test" do
      post :recheck, params: {pod_id: 1}
      expect(response).to be_redirect
    end

    it "performs a connection test (format: json)" do
      post :recheck, params: {pod_id: 1}, format: :json
      expect(response.body).to eql(PodPresenter.new(@pod).to_json)
    end
  end
end
