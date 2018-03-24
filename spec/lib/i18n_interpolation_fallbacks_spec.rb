# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

describe "i18n interpolation fallbacks" do
  describe "when string does not require interpolation arguments" do
    it "works normally" do
      expect(
        I18n.t("user.already_authenticated",
               resource_name: "user",
               scope:         "devise.failure",
               default:       [:already_authenticated, "already_authenticated"])
      ).to eq("You are already signed in.")
    end
  end
  describe "when string requires interpolation arguments" do
    context "current locale has no fallbacks" do
      # tags.show.follow: "Follow #%{tag}" (in en.yml)
      it "returns the translation when all arguments are provided" do
        expect(I18n.t("tags.show.follow", tag: "cats")).to eq("Follow #cats")
      end
      it "returns the translation without substitution when all arguments are omitted" do
        expect(I18n.t("tags.show.follow")).to eq("Follow #%{tag}")
      end
      it "raises a MissingInterpolationArgument when arguments are wrong" do
        expect { I18n.t("tags.show.follow", not_tag: "cats") }.to raise_exception(I18n::MissingInterpolationArgument)
      end
    end
    context "current locale falls back to English" do
      before do
        @old_locale = I18n.locale
        I18n.locale = 'it'
        I18n.backend.store_translations('it', {"nonexistant_key" => "%{random_key} here is some Italian"})
      end
      after do
        I18n.locale = @old_locale
      end
      describe "when all arguments are provided" do
        it "returns the locale's translation" do
          expect(I18n.t('nonexistant_key', :random_key => "Hi Alex,")).to eq("Hi Alex, here is some Italian")
        end
      end
      describe "when no arguments are provided" do
        it "returns the locale's translation without substitution" do
          expect(I18n.t('nonexistant_key')).to eq("%{random_key} here is some Italian")
        end
      end
      describe "when arguments are wrong" do
        describe "when the English translation works" do
          it "falls back to English" do
            I18n.backend.store_translations('en', {"nonexistant_key" => "Working English translation"})
            expect(I18n.t('nonexistant_key', :hey => "what")).to eq("Working English translation")
          end
        end
        describe "when the English translation does not work" do
          it "raises a MissingInterpolationArgument" do
            I18n.backend.store_translations('en', {"nonexistant_key" => "%{random_key} also required, so this will fail"})
            expect { I18n.t('nonexistant_key', :hey => "what") }.to raise_exception(I18n::MissingInterpolationArgument)
          end
        end
      end
    end
  end
end
