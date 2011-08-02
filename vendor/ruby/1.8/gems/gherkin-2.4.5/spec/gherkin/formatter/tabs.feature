Feature: Adding

	Scenario: Add two numbers
		Given the following input:
			"""
			hello
			"""
		When the calculator is run
		Then the output should be 4
