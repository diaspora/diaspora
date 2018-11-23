# frozen_string_literal: true

describe Api::OpenidConnect::ClientsController, type: :controller, suppress_csrf_verification: :none do
  describe "#create" do
    context "when valid parameters are passed" do
      it "should return a client id" do
        stub_request(:get, "http://example.com/uris")
          .with(headers: {
                  "Accept"          => "*/*",
                  "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
                  "User-Agent"      => "Faraday v#{Faraday::VERSION}"
                })
          .to_return(status: 200, body: "[\"http://localhost\"]", headers: {})
        post :create, params: {redirect_uris: ["http://localhost"], client_name: "diaspora client",
             response_types: [], grant_types: [], application_type: "web", contacts: [],
             logo_uri: "http://example.com/logo.png", client_uri: "http://example.com/client",
             policy_uri: "http://example.com/policy", tos_uri: "http://example.com/tos",
             sector_identifier_uri: "http://example.com/uris", subject_type: "pairwise"}
        client_json = JSON.parse(response.body)
        expect(client_json["client_id"].length).to eq(32)
        expect(client_json["ppid"]).to eq(true)
      end
    end

    context "when valid parameters with jwks is passed" do
      it "should return a client id" do
        stub_request(:get, "http://example.com/uris")
          .with(headers: {
                  "Accept"          => "*/*",
                  "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
                  "User-Agent"      => "Faraday v#{Faraday::VERSION}"
                })
          .to_return(status: 200, body: "[\"http://localhost\"]", headers: {})
        post :create, params: {redirect_uris: ["http://localhost"], client_name: "diaspora client",
             response_types: [], grant_types: [], application_type: "web", contacts: [],
             logo_uri: "http://example.com/logo.png", client_uri: "http://example.com/client",
             policy_uri: "http://example.com/policy", tos_uri: "http://example.com/tos",
             sector_identifier_uri: "http://example.com/uris", subject_type: "pairwise",
             token_endpoint_auth_method: "private_key_jwt",
             jwks: {
               keys:
                     [
                       {
                         use: "enc",
                         e:   "AQAB",
                         d:   "-lTBWkI-----lvCO6tuiDsR4qgJnUwnndQFwEI_4mLmD3iNWXrc8N--5Cjq55eLtuJjtvuQ",
                         n:   "--zYRQNDvIVsBDLQQIgrbctuGqj6lrXb31Jj3JIEYqH_4h5X9d0Q",
                         q:   "1q-r----pFtyTz_JksYYaotc_Z3Zy-Szw6a39IDbuYGy1qL-15oQuc",
                         p:   "-BfRjdgYouy4c6xAnGDgSMTip1YnPRyvbMaoYT9E_tEcBW5wOeoc",
                         kid: "a0",
                         kty: "RSA"
                       },
                       {
                         use: "sig",
                         e:   "AQAB",
                         d:   "--x-gW---LRPowKrdvTuTo2p--HMI0pIEeFs7H_u5OW3jihjvoFClGPynHQhgWmQzlQRvWRXh6FhDVqFeGQ",
                         n:   "---TyeadDqQPWgbqX69UzcGq5irhzN8cpZ_JaTk3Y_uV6owanTZLVvCgdjaAnMYeZhb0KFw",
                         q:   "5E5XKK5njT--Hx3nF5sne5fleVfU-sZy6Za4B2U75PcE62oZgCPauOTAEm9Xuvrt5aMMovyzR8ecJZhm9bw7naU",
                         p:   "-BUGA-",
                         kid: "a1",
                         kty: "RSA"},
                       {
                         use: "sig",
                         crv: "P-256",
                         kty: "EC",
                         y:   "Yg4IRzHBMIsuQK2Oz0Uukp1aNDnpdoyk6QBMtmfGHQQ",
                         x:   "L0WUeVlc9r6YJd6ie9duvOU1RHwxSkJKA37IK9B4Bpc",
                         kid: "a2"
                       },
                       {
                         use: "enc",
                         crv: "P-256",
                         kty: "EC",
                         y:   "E6E6g5_ziIZvfdAoACctnwOhuQYMvQzA259aftPn59M",
                         x:   "Yu8_BQE2L0f1MqnK0GumZOaj_77Tx70-LoudyRUnLM4",
                         kid: "a3"
                       }
                     ]
             }}
        client_json = JSON.parse(response.body)
        expect(client_json["client_id"].length).to eq(32)
        expect(client_json["ppid"]).to eq(true)
      end
    end

    context "when valid parameters with jwks_uri is passed" do
      it "should return a client id" do
        stub_request(:get, "http://example.com/uris")
          .with(headers: {
                  "Accept"          => "*/*",
                  "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
                  "User-Agent"      => "Faraday v#{Faraday::VERSION}"
                })
          .to_return(status: 200, body: "[\"http://localhost\"]", headers: {})
        stub_request(:get, "https://kentshikama.com/api/openid_connect/jwks.json")
          .with(headers: {
                  "Accept"          => "*/*",
                  "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
                  "User-Agent"      => "Faraday v#{Faraday::VERSION}"
                })
          .to_return(status: 200,
                     body: "{\"keys\":[{\"kty\":\"RSA\",\"e\":\"AQAB\",\"n\":\"qpW\",\"use\":\"sig\"}]}", headers: {})
        post :create, params: {redirect_uris: ["http://localhost"], client_name: "diaspora client",
             response_types: [], grant_types: [], application_type: "web", contacts: [],
             logo_uri: "http://example.com/logo.png", client_uri: "http://example.com/client",
             policy_uri: "http://example.com/policy", tos_uri: "http://example.com/tos",
             sector_identifier_uri: "http://example.com/uris", subject_type: "pairwise",
             token_endpoint_auth_method: "private_key_jwt",
             jwks_uri: "https://kentshikama.com/api/openid_connect/jwks.json"}
        client_json = JSON.parse(response.body)
        expect(client_json["client_id"].length).to eq(32)
        expect(client_json["ppid"]).to eq(true)
      end
    end

    context "when redirect uri is missing" do
      it "should return a invalid_client_metadata error" do
        post :create, params: {response_types: [], grant_types: [], application_type: "web", contacts: [],
          logo_uri: "http://example.com/logo.png", client_uri: "http://example.com/client",
          policy_uri: "http://example.com/policy", tos_uri: "http://example.com/tos"}
        client_json = JSON.parse(response.body)
        expect(client_json["error"]).to have_content("invalid_client_metadata")
      end
    end
  end

  describe "#find" do
    let!(:client) { FactoryGirl.create(:o_auth_application) }

    context "when an OIDC client already exists" do
      it "should return a client id" do
        get :find, params: {client_name: client.client_name}
        client_id_json = JSON.parse(response.body)
        expect(client_id_json["client_id"]).to eq(client.client_id)
      end
    end

    context "when an OIDC client doesn't already exist" do
      it "should return the appropriate error" do
        get :find, params: {client_name: "random_name"}
        client_id_json = JSON.parse(response.body)
        expect(client_id_json["error"]).to eq("Client with name random_name does not exist")
      end
    end
  end
end
