# frozen_sTring_literal: true

require_relative "api_spec_helper"

describe Api::V1::AspectsController do
  let(:auth) {
    FactoryGirl.create(
      :auth_with_default_scopes,
      scopes: %w[openid contacts:read contacts:modify]
    )
  }

  let(:auth_read_only) {
    FactoryGirl.create(
      :auth_with_default_scopes,
      scopes: %w[openid contacts:read]
    )
  }

  let(:auth_minimum_scopes) {
    FactoryGirl.create(:auth_with_default_scopes)
  }

  let!(:access_token) { auth.create_access_token.to_s }
  let!(:access_token_read_only) { auth_read_only.create_access_token.to_s }
  let!(:access_token_minimum_scopes) { auth_minimum_scopes.create_access_token.to_s }
  let(:invalid_token) { SecureRandom.hex(9) }

  before do
    @aspect1 = auth.user.aspects.create(name: "first aspect")
    @aspect2 = auth.user.aspects.create(name: "second aspect")
  end

  describe "#index" do
    it "returns list of aspects" do
      get(
        api_v1_aspects_path,
        params: {access_token: access_token}
      )
      expect(response.status).to eq(200)
      aspects = response_body_data(response)
      expect(aspects.length).to eq(auth.user.aspects.length)
      aspects.each do |aspect|
        found_aspect = auth.user.aspects.find_by(id: aspect["id"])
        expect(aspect["name"]).to eq(found_aspect.name)
        expect(aspect["order"]).to eq(found_aspect.order_id)
      end

      expect(aspects.to_json).to match_json_schema(:api_v1_schema, fragment: "#/definitions/aspects")
    end

    context "without impromper credentials" do
      it "fails if token doesn't have contacts:read" do
        get(
          api_v1_aspects_path,
          params: {access_token: access_token_minimum_scopes}
        )
        expect(response.status).to eq(403)
      end

      it "fails if invalid token" do
        get(
          api_v1_aspects_path,
          params: {access_token: invalid_token}
        )
        expect(response.status).to eq(401)
      end
    end
  end

  describe "#show" do
    context "with correct id" do
      it "returns aspect" do
        get(
          api_v1_aspect_path(@aspect2.id),
          params: {access_token: access_token}
        )
        expect(response.status).to eq(200)
        aspect = JSON.parse(response.body)
        expect(aspect["id"]).to eq(@aspect2.id)
        expect(aspect["name"]).to eq(@aspect2.name)
        expect(aspect["order"]).to eq(@aspect2.order_id)

        expect(aspect.to_json).to match_json_schema(:api_v1_schema, fragment: "#/definitions/aspect")
      end
    end

    context "with incorrect id" do
      it "fails to return with error" do
        get(
          api_v1_aspect_path("-1"),
          params: {access_token: access_token}
        )
        confirm_api_error(response, 404, "Aspect with provided ID could not be found")
      end
    end

    context "without impromper credentials" do
      it "fails without contacts:read in token" do
        get(
          api_v1_aspect_path(@aspect2.id),
          params: {access_token: access_token_minimum_scopes}
        )
        expect(response.status).to eq(403)
      end

      it "fails when not logged in" do
        get(
          api_v1_aspect_path(@aspect2.id),
          params: {access_token: invalid_token}
        )
        expect(response.status).to eq(401)
      end
    end
  end

  describe "#create" do
    context "with full aspect settings" do
      it "creates aspect" do
        new_name = "diaspora developers"
        post(
          api_v1_aspects_path,
          params: {name: new_name, access_token: access_token}
        )

        expect(response.status).to eq(200)
        aspect = JSON.parse(response.body)
        expect(aspect["name"]).to eq(new_name)
        expect(aspect.has_key?("id")).to be_truthy
        expect(aspect.has_key?("order")).to be_truthy
      end

      it "fails to create duplicate aspect" do
        post(
          api_v1_aspects_path,
          params: {name: @aspect1.name, access_token: access_token}
        )

        confirm_api_error(response, 422, "Failed to create the aspect")
      end
    end

    context "with malformed settings" do
      it "fails when missing name" do
        post(
          api_v1_aspects_path,
          params: {order: 0, access_token: access_token}
        )

        confirm_api_error(response, 422, "Failed to create the aspect")
      end
    end

    context "improper credentials" do
      it "fails when not logged in" do
        post(
          api_v1_aspects_path,
          params: {name: "new_name", access_token: invalid_token}
        )
        expect(response.status).to eq(401)
      end

      it "fails when logged in read only" do
        post(
          api_v1_aspects_path,
          params: {name: "new_name", access_token: access_token_read_only}
        )

        expect(response.status).to eq(403)
      end
    end
  end

  describe "#update" do
    context "with aspect settings" do
      it "updates full aspect" do
        new_name = "NewAspectName"
        new_order = @aspect2.order_id + 1
        patch(
          api_v1_aspect_path(@aspect2.id),
          params: {name: new_name, order: new_order, access_token: access_token}
        )

        expect(response.status).to eq(200)
        aspect = JSON.parse(response.body)
        expect(aspect["name"]).to eq(new_name)
        expect(aspect["order"]).to eq(new_order)
        expect(aspect["id"]).to eq(@aspect2.id)
      end

      it "updates name only aspect" do
        new_name = "NewAspectName"
        patch(
          api_v1_aspect_path(@aspect2.id),
          params: {name: new_name, access_token: access_token}
        )

        expect(response.status).to eq(200)
        aspect = JSON.parse(response.body)
        expect(aspect["name"]).to eq(new_name)
        expect(aspect["id"]).to eq(@aspect2.id)
      end

      it "updates order only" do
        new_order = @aspect2.order_id + 1
        patch(
          api_v1_aspect_path(@aspect2.id),
          params: {order: new_order, access_token: access_token}
        )

        expect(response.status).to eq(200)
        aspect = JSON.parse(response.body)
        expect(aspect["order"]).to eq(new_order)
        expect(aspect["id"]).to eq(@aspect2.id)
      end

      it "succeds with no arguments" do
        patch(
          api_v1_aspect_path(@aspect2.id),
          params: {access_token: access_token}
        )

        expect(response.status).to eq(200)
        aspect = JSON.parse(response.body)
        expect(aspect["name"]).to eq(@aspect2.name)
        expect(aspect["id"]).to eq(@aspect2.id)
      end
    end

    context "with bad parameters" do
      it "fails with reused name" do
        patch(
          api_v1_aspect_path(@aspect2.id),
          params: {name: @aspect1.name, access_token: access_token}
        )

        confirm_api_error(response, 422, "Failed to update the aspect")
      end

      it "fails with bad id" do
        patch(
          api_v1_aspect_path("-1"),
          params: {name: "NewAspectName", access_token: access_token}
        )

        confirm_api_error(response, 404, "Failed to update the aspect")
      end
    end

    context "improper credentials" do
      it "fails when not logged in" do
        patch(
          api_v1_aspect_path(@aspect2.id),
          params: {access_token: invalid_token}
        )
        expect(response.status).to eq(401)
      end

      it "fails when logged in read only" do
        patch(
          api_v1_aspect_path(@aspect2.id),
          params: {access_token: access_token_read_only}
        )
        expect(response.status).to eq(403)
      end
    end
  end

  describe "#delete" do
    context "with correct ID" do
      it "deletes aspect" do
        delete(
          api_v1_aspect_path(@aspect2.id),
          params: {access_token: access_token}
        )
        expect(response.status).to eq(204)
        expect(auth.user.aspects.find_by(id: @aspect2.id)).to be_nil
      end
    end

    context "with bad ID" do
      it "fails to delete with error" do
        delete(
          api_v1_aspect_path("-1"),
          params: {access_token: access_token}
        )
        confirm_api_error(response, 422, "Failed to delete the aspect")
      end
    end

    context "improper credentials" do
      it "fails when not logged in" do
        delete(
          api_v1_aspect_path(@aspect2.id),
          params: {access_token: invalid_token}
        )
        expect(response.status).to eq(401)
      end

      it "fails when logged in read only" do
        delete(
          api_v1_aspect_path(@aspect2.id),
          params: {access_token: access_token_read_only}
        )
        expect(response.status).to eq(403)
      end
    end
  end

  def response_body_data(response)
    JSON.parse(response.body)
  end
end
