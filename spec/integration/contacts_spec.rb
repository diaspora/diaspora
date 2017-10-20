# frozen_string_literal: true

describe ContactsController, type: :request do
  describe "/contacts" do
    context "user is signed in" do
      before do
        sign_in user
      end

      shared_examples_for "community spotlight information is not present on the page" do
        it "does not display a community spotlight link" do
          get "/contacts"

          expect(response.status).to eq(200)
          expect(response.body).to_not match(/a href="#{community_spotlight_path}"/)
        end
      end

      context "user has no contacts" do
        let!(:user) { FactoryGirl.create(:user) }

        before do
          expect(user.contacts.size).to eq(0)
        end

        context "community spotlight is enabled" do
          before do
            AppConfig.settings.community_spotlight.enable = true
          end

          it "displays a community spotlight link" do
            get "/contacts"

            expect(response.status).to eq(200)
            expect(response.body).to match(/a href="#{community_spotlight_path}"/)
          end
        end

        context "community spotlight is disabled" do
          before do
            AppConfig.settings.community_spotlight.enable = false
          end

          it_behaves_like "community spotlight information is not present on the page"
        end
      end

      context "user has contacts" do
        let!(:user) { FactoryGirl.create(:user) }

        before do
          FactoryGirl.create(:contact, person: alice.person, user: user)
          FactoryGirl.create(:contact, person: bob.person, user: user)
          expect(user.reload.contacts.size).to eq(2)
        end

        context "community spotlight is enabled" do
          before do
            AppConfig.settings.community_spotlight.enable = true
          end

          it_behaves_like "community spotlight information is not present on the page"
        end

        context "community spotlight is disabled" do
          before do
            AppConfig.settings.community_spotlight.enable = false
          end

          it_behaves_like "community spotlight information is not present on the page"
        end
      end
    end
  end
end
