# frozen_string_literal: true

describe 'locale files' do
  describe "cldr/plurals.rb" do
    AVAILABLE_LANGUAGE_CODES.each do |locale|
      describe "#{locale} plural rules" do
        it "defines the keys for #{locale}" do
          I18n.with_locale locale do
            expect {
              I18n.t 'i18n.plural.keys'
            }.to_not raise_error
          end
        end

        it "defines a valid pluralization function for #{locale}" do
          I18n.with_locale locale do
            expect {
              rule = I18n.t 'i18n.plural.rule', resolve: false
              rule.call(1)
            }.to_not raise_error
          end
        end

        it "defines a valid javascript pluralization function for #{locale}" do
          I18n.with_locale locale do
            expect {
              ExecJS.eval I18n.t('i18n.plural.js_rule')
            }.to_not raise_error
          end
        end
      end
    end
  end

  AVAILABLE_LANGUAGE_CODES.each do |locale|
    ["diaspora/#{locale}.yml",
     "devise/devise.#{locale}.yml",
     "javascript/javascript.#{locale}.yml"].each do |file|
      describe file do
        it "has no syntax errors if it exists" do
          file = Rails.root.join("config", "locales", file)
          skip "Not yet available" unless File.exists? file
          expect {
            YAML.load_file file
          }.to_not raise_error
        end
      end
    end
  end
end
