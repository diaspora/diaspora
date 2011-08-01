Feature: User pages
	Make sure user pages work as required.

	Background:
		Given a user with username "cogitoergosum"

	Scenario: Visit an existing user's profile page
		Given configuration parameter pod_url is http://localhost:9887/
		When I visit url http://localhost:9887/u/cogitoergosum
		Then I should see "cogitoergosum@localhost:9887"
		And I should not see "500: Internal Server Error"

	Scenario: Visit a non-existing user's profile page
		Given configuration parameter pod_url is http://localhost:9887/
		When I visit url http://localhost:9887/u/idonotexist
		Then I should not see "500: Internal Server Error"
