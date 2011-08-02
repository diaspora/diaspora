Feature: JUnit output formatter
  In order for developers to create test reports with ant
  Cucumber should be able to output JUnit xml files
  
  Background:
    Given I am in junit
    And the tmp directory is empty
  
  Scenario: one feature, one passing scenario, one failing scenario
    When I run cucumber --format junit --out tmp/ features/one_passing_one_failing.feature
    Then it should fail with
      """

      """
    And "fixtures/junit/tmp/TEST-features-one_passing_one_failing.xml" with junit duration "0.005" should contain
      """
      <?xml version="1.0" encoding="UTF-8"?>
      <testsuite errors="0" failures="1" name="One passing scenario, one failing scenario" skipped="0" tests="2" time="0.005">
      <testcase classname="One passing scenario, one failing scenario.Passing" name="Passing" time="0.005">
      </testcase>
      <testcase classname="One passing scenario, one failing scenario.Failing" name="Failing" time="0.005">
        <failure message="failed Failing" type="failed">
          <![CDATA[Scenario: Failing

      Given a failing scenario

      Message:
	]]>
          <![CDATA[ (RuntimeError)
	features/one_passing_one_failing.feature:7:in `Given a failing scenario']]>
        </failure>
      </testcase>
      </testsuite>

      """
  
  Scenario: one feature in a subdirectory, one passing scenario, one failing scenario
    When I run cucumber --format junit --out tmp/ features/some_subdirectory/one_passing_one_failing.feature --require features
    Then it should fail with
      """

      """
    And "fixtures/junit/tmp/TEST-features-some_subdirectory-one_passing_one_failing.xml" with junit duration "0.005" should contain
      """
      <?xml version="1.0" encoding="UTF-8"?>
      <testsuite errors="0" failures="1" name="Subdirectory - One passing scenario, one failing scenario" skipped="0" tests="2" time="0.005">
      <testcase classname="Subdirectory - One passing scenario, one failing scenario.Passing" name="Passing" time="0.005">
      </testcase>
      <testcase classname="Subdirectory - One passing scenario, one failing scenario.Failing" name="Failing" time="0.005">
        <failure message="failed Failing" type="failed">
          <![CDATA[Scenario: Failing

      Given a failing scenario

      Message:
	]]>
          <![CDATA[ (RuntimeError)
	features/some_subdirectory/one_passing_one_failing.feature:7:in `Given a failing scenario']]>
        </failure>
      </testcase>
      </testsuite>

      """
  
  Scenario: pending and undefined steps are reported as skipped
    When I run cucumber --format junit --out tmp/ features/pending.feature
    Then it should pass with
      """
      
      """
    And "fixtures/junit/tmp/TEST-features-pending.xml" with junit duration "0.009" should contain
      """
      <?xml version="1.0" encoding="UTF-8"?>
      <testsuite errors="0" failures="0" name="Pending step" skipped="2" tests="2" time="0.009">
      <testcase classname="Pending step.Pending" name="Pending" time="0.009">
        <skipped/>
      </testcase>
      <testcase classname="Pending step.Undefined" name="Undefined" time="0.009">
        <skipped/>
      </testcase>
      </testsuite>
      
      """

  Scenario: pending and undefined steps with strict option should fail
    When I run cucumber --format junit --out tmp/ features/pending.feature --strict
    Then it should fail with
      """

      """
    And "fixtures/junit/tmp/TEST-features-pending.xml" with junit duration "0.000160" should contain
      """
      <?xml version="1.0" encoding="UTF-8"?>
      <testsuite errors="0" failures="2" name="Pending step" skipped="0" tests="2" time="0.000160">
      <testcase classname="Pending step.Pending" name="Pending" time="0.000160">
        <failure message="pending Pending" type="pending">
          <![CDATA[Scenario: Pending

      ]]>
          <![CDATA[TODO (Cucumber::Pending)
      features/pending.feature:4:in `Given a pending step']]>
        </failure>
      </testcase>
      <testcase classname="Pending step.Undefined" name="Undefined" time="0.000160">
        <failure message="undefined Undefined" type="undefined">
          <![CDATA[Scenario: Undefined
      
      ]]>
          <![CDATA[Undefined step: "an undefined step" (Cucumber::Undefined)
      features/pending.feature:7:in `Given an undefined step']]>
        </failure>
      </testcase>
      </testsuite>

      """
    
  Scenario: run all features
    When I run cucumber --format junit --out tmp/ features
    Then it should fail with
      """
      
      """
    And "fixtures/junit/tmp/TEST-features-one_passing_one_failing.xml" should exist
    And "fixtures/junit/tmp/TEST-features-pending.xml" should exist
  
  Scenario: show correct error message if no --out is passed
    When I run cucumber --format junit features
    Then STDERR should not match 
      """
can't convert .* into String \(TypeError\)
      """
    And STDERR should match
      """
You \*must\* specify \-\-out DIR for the junit formatter
      """

  Scenario: one feature, one scenario outline, two examples: one passing, one failing
    When I run cucumber --format junit --out tmp/ features/scenario_outline.feature
    Then it should fail with
      """

      """
    And "fixtures/junit/tmp/TEST-features-scenario_outline.xml" with junit duration "0.005" should contain
      """
      <?xml version="1.0" encoding="UTF-8"?>
      <testsuite errors="0" failures="1" name="Scenario outlines" skipped="0" tests="2" time="0.005">
      <testcase classname="Scenario outlines.Using scenario outlines" name="Using scenario outlines (outline example : | passing |)" time="0.005">
      </testcase>
      <testcase classname="Scenario outlines.Using scenario outlines" name="Using scenario outlines (outline example : | failing |)" time="0.005">
        <failure message="failed Using scenario outlines (outline example : | failing |)" type="failed">
          <![CDATA[Scenario Outline: Using scenario outlines
      
      Example row: | failing |
      
      Message:
      ]]>
          <![CDATA[ (RuntimeError)
      features/scenario_outline.feature:4:in `Given a <type> scenario']]>
        </failure>
      </testcase>
      </testsuite>

      """
  