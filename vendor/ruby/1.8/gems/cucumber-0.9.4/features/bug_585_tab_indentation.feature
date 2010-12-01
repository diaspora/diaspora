# Make sure tab indentation is preserved in this feature!
Feature: https://rspec.lighthouseapp.com/projects/16211/tickets/585
	Scenario: Tab indentation should work
    	Given a standard Cucumber project directory structure
    	And a file named "features/f.feature" with:
		"""
		Feature: developer creates a skeleton Ruby application
			Scenario: create a new application
				Given a tab indented pystring:
				\"\"\"
				I'm tab
				 and space indented
				\"\"\"
			And a file named "features/step_definitions/steps.rb" with:
				\"\"\"
				Given /a tab indented pystring:/ do |s| s.should == "I'm tab\n and space indented"
				end
				\"\"\"
		"""
		When I run cucumber features/f.feature
		Then STDERR should be empty
		And it should pass
