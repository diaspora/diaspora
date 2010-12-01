Feature: JSON output formatter
  In order to get results as data
  As a developer
  Cucumber should be able to output JSON

  Background:
    Given I am in json

  Scenario: one feature, one passing scenario, one failing scenario
    And the tmp directory is empty
    When I run cucumber --format json --out tmp/out.json features/one_passing_one_failing.feature
    Then STDERR should be empty
    And it should fail with
      """
      """
    And "fixtures/json/tmp/out.json" should match "^\{\"features\":\["

  Scenario: one feature, one passing scenario, one failing scenario
    When I run cucumber --format json_pretty features/one_passing_one_failing.feature
    Then STDERR should be empty
    And it should fail with JSON
      """
      {
        "features": [
          {
            "file": "features/one_passing_one_failing.feature",
            "name": "One passing scenario, one failing scenario",
            "tags": [
              "@a"
            ],
            "elements": [
              {
                "tags": [
                  "@b"
                ],
                "keyword": "Scenario",
                "name": "Passing",
                "file_colon_line": "features/one_passing_one_failing.feature:5",
                "steps": [
                  {
                    "status": "passed",
                    "keyword": "Given ",
                    "name": "a passing step",
                    "file_colon_line": "features/step_definitions/steps.rb:1"
                  }
                ]
              },
              {
                "tags": [
                  "@c"
                ],
                "keyword": "Scenario",
                "name": "Failing",
                "file_colon_line": "features/one_passing_one_failing.feature:9",
                "steps": [
                  {
                    "exception": {
                      "class": "RuntimeError",
                      "message": "",
                      "backtrace": [
                        "./features/step_definitions/steps.rb:6:in `/a failing step/'",
                        "features/one_passing_one_failing.feature:10:in `Given a failing step'"
                      ]
                    },
                    "status": "failed",
                    "keyword": "Given ",
                    "name": "a failing step",
                    "file_colon_line": "features/step_definitions/steps.rb:5"
                  }
                ]
              }
            ]
          }
        ]
      }
      """

  Scenario: Tables
    When I run cucumber --format json_pretty features/tables.feature
    Then STDERR should be empty
    And it should fail with JSON
      """
      {
        "features": [
          {
            "file": "features/tables.feature",
            "name": "A scenario outline",
            "tags": [

            ],
            "elements": [
              {
                "tags": [

                ],
                "keyword": "Scenario Outline",
                "name": "",
                "file_colon_line": "features/tables.feature:3",
                "steps": [
                  {
                    "status": "skipped",
                    "keyword": "Given ",
                    "name": "I add <a> and <b>",
                    "file_colon_line": "features/step_definitions/steps.rb:13"
                  },
                  {
                    "status": "skipped",
                    "keyword": "When ",
                    "name": "I pass a table argument",
                    "file_colon_line": "features/step_definitions/steps.rb:25",
                    "table": [
                      {"cells":
                        [{"text":"foo", "status": null},
                         {"text":"bar", "status": null}]},
                      {"cells":
                        [{"text": "bar", "status": null},
                         {"text": "baz", "status": null}]}
                    ]
                  },
                  {
                     "status": "skipped",
                     "keyword": "Then ",
                     "name": "I the result should be <c>",
                     "file_colon_line": "features/step_definitions/steps.rb:17"
                  }
                ],
                "examples": {
                  "name": "Examples ",
                  "table": [
                    {
                      "cells": [
                        {
                          "text": "a",
                          "status": "skipped_param"
                        },
                        {
                          "text": "b",
                          "status": "skipped_param"
                        },
                        {
                          "text": "c",
                          "status": "skipped_param"
                        }
                      ]
                    },
                    {
                      "cells": [
                        {
                          "text": "1",
                          "status": "passed"
                        },
                        {
                          "text": "2",
                          "status": "passed"
                        },
                        {
                          "text": "3",
                          "status": "passed"
                        }
                      ]
                    },
                    {
                      "cells": [
                        {
                          "text": "2",
                          "status": "passed"
                        },
                        {
                          "text": "3",
                          "status": "passed"
                        },
                        {
                          "text": "4",
                          "status": "failed"
                        }
                      ],
                      "exception": {
                        "class": "RSpec::Expectations::ExpectationNotMetError",
                        "message": "expected: 4,\n     got: 5 (using ==)",
                        "backtrace": [
                          "./features/step_definitions/steps.rb:18:in `/^I the result should be (\\d+)$/'",
                          "features/tables.feature:8:in `Then I the result should be <c>'"
                        ]
                      }
                    }
                  ]
                }
              }
            ]
          }
        ]
      }
      """

  Scenario: pystring
    When I run cucumber --format json_pretty features/pystring.feature
    Then STDERR should be empty
    And it should pass with JSON
    """
      {
        "features": [
          {
            "file": "features/pystring.feature",
            "name": "A py string feature",
            "tags": [

            ],
            "elements": [
              {
                "tags": [

                ],
                "keyword": "Scenario",
                "name": "",
                "file_colon_line": "features/pystring.feature:3",
                "steps": [
                  {
                    "status": "passed",
                    "keyword": "Then ",
                    "name": "I should see",
                    "file_colon_line": "features/step_definitions/steps.rb:21",
                    "py_string": "a string"
                  }
                ]
              }
            ]
          }
        ]
      }
    """

  Scenario: background
    When I run cucumber --format json_pretty features/background.feature
    Then STDERR should be empty
    And it should fail with JSON
    """
    {
      "features": [
        {
          "file": "features/background.feature",
          "name": "Feature with background",
          "tags": [

          ],
          "background": {
            "steps": [
              {
                "status": "passed",
                "keyword": "Given ",
                "name": "a passing step",
                "file_colon_line": "features/step_definitions/steps.rb:1"
              }
            ]
          },
          "elements": [
            {
              "tags": [

              ],
              "keyword": "Scenario",
              "name": "",
              "file_colon_line": "features/background.feature:6",
              "steps": [
                {
                  "status": "passed",
                  "keyword": "Given ",
                  "name": "a passing step",
                  "file_colon_line": "features/step_definitions/steps.rb:1"
                },
                {
                  "exception": {
                    "class": "RuntimeError",
                    "message": "",
                    "backtrace": [
                      "./features/step_definitions/steps.rb:6:in `/a failing step/'",
                      "features/background.feature:7:in `Given a failing step'"
                    ]
                  },
                  "status": "failed",
                  "keyword": "Given ",
                  "name": "a failing step",
                  "file_colon_line": "features/step_definitions/steps.rb:5"
                }
              ]
            }
          ]
        }
      ]
    }
    """

  Scenario: embedding screenshot
    When I run cucumber --format json_pretty features/embed.feature
    Then STDERR should be empty
    And it should pass with JSON
    """
    {
      "features": [
        {
          "file": "features/embed.feature",
          "name": "A screenshot feature",
          "tags": [

          ],
          "elements": [
            {
              "tags": [

              ],
              "keyword": "Scenario",
              "name": "",
              "file_colon_line": "features/embed.feature:3",
              "steps": [
                {
                  "status": "passed",
                  "keyword": "Given ",
                  "name": "I embed a screenshot",
                  "file_colon_line": "features/step_definitions/steps.rb:29",
                  "embedded": [
                    {
                      "file": "tmp/screenshot.png",
                      "mime_type": "image/png",
                      "data": "Zm9v\n"
                    }
                  ]
                }
              ]
            }
          ]
        }
      ]
    }
    """