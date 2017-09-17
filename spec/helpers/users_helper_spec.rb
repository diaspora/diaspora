# frozen_string_literal: true

describe UsersHelper, type: :helper do
  include Devise::Test::ControllerHelpers

  describe "#current_color_theme" do
    describe "if user is not signed in" do
      before do
        def user_signed_in?
          false
        end
      end

      it "returns the default color theme" do
        expect(current_color_theme).to eq("color_themes/#{AppConfig.settings.default_color_theme}")
      end
    end

    describe "if user is signed in" do
      before do
        @user = User.new
        def user_signed_in?
          true
        end

        def current_user
          @user
        end
      end

      it "returns the default color theme if user has not selected any theme" do
        expect(current_color_theme).to eq("color_themes/#{AppConfig.settings.default_color_theme}")
      end

      it "returns the color theme selected by the user if there is a selected one" do
        selected_theme = "test_theme"
        @user.color_theme = selected_theme
        expect(current_color_theme).to eq("color_themes/#{selected_theme}")
      end
    end
  end
end
