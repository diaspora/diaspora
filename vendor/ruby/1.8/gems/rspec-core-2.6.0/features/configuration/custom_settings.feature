Feature: custom settings

  Extensions like rspec-rails can add their own configuration settings.

  Scenario: simple setting (with defaults)
    Given a file named "additional_setting_spec.rb" with:
      """
      RSpec.configure do |c|
        c.add_setting :custom_setting
      end

      describe "custom setting" do
        it "is nil by default" do
          RSpec.configuration.custom_setting.should be_nil
        end

        it "acts false by default" do
          RSpec.configuration.custom_setting.should be_false
        end

        it "is exposed as a predicate" do
          RSpec.configuration.custom_setting?.should be_false
        end

        it "can be overridden" do
          RSpec.configuration.custom_setting = true
          RSpec.configuration.custom_setting.should be_true
          RSpec.configuration.custom_setting?.should be_true
        end
      end
      """
    When I run `rspec ./additional_setting_spec.rb`
    Then the examples should all pass

  Scenario: default to true
    Given a file named "additional_setting_spec.rb" with:
      """
      RSpec.configure do |c|
        c.add_setting :custom_setting, :default => true
      end

      describe "custom setting" do
        it "is true by default" do
          RSpec.configuration.custom_setting.should be_true
        end

        it "is exposed as a predicate" do
          RSpec.configuration.custom_setting?.should be_true
        end

        it "can be overridden" do
          RSpec.configuration.custom_setting = false
          RSpec.configuration.custom_setting.should be_false
          RSpec.configuration.custom_setting?.should be_false
        end
      end
      """
    When I run `rspec ./additional_setting_spec.rb`
    Then the examples should all pass

  Scenario: overridden in a subsequent RSpec.configure block
    Given a file named "additional_setting_spec.rb" with:
      """
      RSpec.configure do |c|
        c.add_setting :custom_setting
      end

      RSpec.configure do |c|
        c.custom_setting = true
      end

      describe "custom setting" do
        it "returns the value set in the last cofigure block to get eval'd" do
          RSpec.configuration.custom_setting.should be_true
        end

        it "is exposed as a predicate" do
          RSpec.configuration.custom_setting?.should be_true
        end
      end
      """
    When I run `rspec ./additional_setting_spec.rb`
    Then the examples should all pass

