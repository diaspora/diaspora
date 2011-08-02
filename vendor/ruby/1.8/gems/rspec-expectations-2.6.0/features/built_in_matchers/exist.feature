Feature: exist matcher

  The exist matcher is used to specify that something exists
  (as indicated by #exist? or #exists?):

    obj.should exist # passes if obj.exist? or obj.exists?

  Scenario: basic usage
    Given a file named "exist_matcher_spec.rb" with:
      """
      class Planet
        attr_reader :name

        def initialize(name)
          @name = name
        end

        def inspect
          "<Planet: #{name}>"
        end

        def exist? # also works with exists?
          %w[Mercury Venus Earth Mars Jupiter Saturn Uranus Neptune].include?(name)
        end
      end

      describe "Earth" do
        let(:earth) { Planet.new("Earth") }
        specify { earth.should exist }
        specify { earth.should_not exist } # deliberate failure
      end

      describe "Tatooine" do
        let(:tatooine) { Planet.new("Tatooine") }
        it { tatooine.should exist } # deliberate failure
        it { tatooine.should_not exist }
      end
      """
    When I run `rspec exist_matcher_spec.rb`
    Then the output should contain all of these:
      | 4 examples, 2 failures                |
      | expected <Planet: Earth> not to exist |
      | expected <Planet: Tatooine> to exist  |
