# frozen_string_literal: true

describe LanguageHelper, type: :helper do
  describe "#get_javascript_strings_for" do
    it "generates a jasmine fixture", fixture: true do
      save_fixture(get_javascript_strings_for("en", "javascripts").to_json, "locale_en_javascripts_json")
      save_fixture(get_javascript_strings_for("en", "help").to_json, "locale_en_help_json")
    end
  end
end
