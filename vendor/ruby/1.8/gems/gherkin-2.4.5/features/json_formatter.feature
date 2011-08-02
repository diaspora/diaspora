Feature: JSON formatter
  In order to support greater access to features
  we want JSON

  Background:
    Given a JSON formatter
    And a "ruby" "root" parser

  Scenario: Only a Feature
    Given the following text is parsed:
      """
      # language: no
      # Another comment
      Egenskap: Kjapp
      """
    Then the outputted JSON should be:
      """
      {
        "comments": [{"value": "# language: no", "line": 1}, {"value": "# Another comment", "line": 2}],
        "keyword": "Egenskap",
        "name": "Kjapp",
        "description": "",
        "line": 3
      }
      """

  Scenario: Feature with scenarios and outlines
    Given the following text is parsed:
      """
      @one
      Feature: OH HAI

        Scenario: Fujin
          Given wind
          Then spirit

        @two
        Scenario: _why
          Given chunky
          Then bacon

        @three @four
        Scenario Outline: Life
          Given some <boredom>

        @five
        Examples: Real life
          |boredom|
          |airport|
          |meeting|

        Scenario: who stole my mojo?
          When I was
            |asleep|
          And so
            \"\"\"
            innocent
            \"\"\"

        # The
        Scenario Outline: with
          # all
          Then nice
          
        # comments
        # everywhere
        Examples: An example
          # I mean
          | partout |
      """
    Then the outputted JSON should be:
      """
      {
        "tags": [{"name": "@one", "line":1}],
        "keyword": "Feature",
        "name": "OH HAI",
        "description": "",
        "line": 2,
        "elements":[
          {
            "type": "scenario",
            "keyword": "Scenario",
            "name": "Fujin",
            "description": "",
            "line": 4,
            "steps": [
              {
                "keyword": "Given ",
                "name": "wind",
                "line": 5
              },
              {
                "keyword": "Then ",
                "name": "spirit",
                "line": 6
              }
            ]
          },
          {
            "type": "scenario",
            "tags": [{"name": "@two", "line":8}],
            "keyword": "Scenario",
            "name": "_why",
            "description": "",
            "line": 9,
            "steps": [
              {
                "keyword": "Given ",
                "name": "chunky",
                "line": 10
              },
              {
                "keyword": "Then ",
                "name": "bacon",
                "line": 11
              }
            ]
          },
          {
            "type": "scenario_outline",
            "tags": [{"name": "@three", "line":13}, {"name": "@four", "line":13}],
            "keyword": "Scenario Outline",
            "name": "Life",
            "description": "",
            "line": 14,
            "steps": [
              {
                "keyword": "Given ",
                "name": "some <boredom>",
                "line": 15
              }
            ],
            "examples": [
              {
                "tags": [{"name": "@five", "line":17}],
                "keyword": "Examples",
                "name": "Real life",
                "description": "",
                "line": 18,
                "rows": [
                  {
                    "cells": ["boredom"],
                    "line": 19
                  },
                  {
                    "cells": ["airport"],
                    "line": 20
                  },
                  {
                    "cells": ["meeting"],
                    "line": 21
                  }
                ]
              }
            ]
          },
          {
            "type": "scenario",
            "keyword": "Scenario",
            "name": "who stole my mojo?",
            "description": "",
            "line": 23,
            "steps": [
              {
                "keyword": "When ",
                "name": "I was",
                "line": 24,
                "multiline_arg": {
                  "type": "table",
                  "value": [
                    {
                      "line": 25,
                      "cells": ["asleep"]
                    }
                  ]
                }
              },
              {
                "keyword": "And ",
                "name": "so",
                "line": 26,
                "multiline_arg": {
                  "type": "doc_string",
                  "value": "innocent",
                  "line": 27
                }
              }
            ]
          },
          {
            "type": "scenario_outline",
            "comments": [{"value": "# The", "line":31}],
            "keyword": "Scenario Outline",
            "name": "with",
            "description": "",
            "line": 32,
            "steps": [
              {
                "comments": [{"value": "# all", "line":33}],
                "keyword": "Then ",
                "line": 34,
                "name": "nice"
              }
            ],
            "examples": [
              {
                "comments": [{"value": "# comments", "line": 36}, {"value": "# everywhere", "line": 37}],
                "keyword": "Examples",
                "name": "An example",
                "description": "",
                "line": 38,
                "rows": [
                  {
                    "comments": [{"value": "# I mean", "line": 39}],
                    "line": 40,
                    "cells": ["partout"]
                  }
                ]
              }
            ]
          }
        ]
      }
      """

  Scenario:  Feature with Background
    Given the following text is parsed:
      """
      Feature: Kjapp

        Background: No idea what Kjapp means
          Given I Google it

        # Writing JSON by hand sucks
        Scenario: 
          Then I think it means "fast"
      """
    Then the outputted JSON should be:
      """
      {
        "keyword": "Feature",
        "name": "Kjapp",
        "description": "",
        "line": 1,
        "elements": [
          {
            "type": "background",
            "keyword": "Background",
            "line": 3,
            "name": "No idea what Kjapp means",
            "description": "",
            "steps": [
              {
                "keyword": "Given ",
                "line": 4,
                "name": "I Google it"
              }
            ]
          },
          {
            "type": "scenario",
            "comments": [{"value": "# Writing JSON by hand sucks", "line": 6}],
            "keyword": "Scenario",
            "name": "",
            "description": "",
            "line": 7,
            "steps": [
              {
                "keyword": "Then ",
                "name": "I think it means \"fast\"",
                "line": 8
              }
            ]
          }
        ]
      }
      """
  
  Scenario: Feature with a description

    We want people to be able to put markdown formatting into their descriptions
    but this means we need to respect whitespace at the start and end of lines
    in the description.
    
    Pay close attention to the whitespace in this example.
    
    Given the following text is parsed:
      """
      Feature: Foo
        one line  
        another line  
        
            some pre-formatted stuff
        
        Background: name
            test  
            test 
        
        Scenario: name
            test  
            test 
        
        Scenario Outline: name
            test  
            test 
          
          Given <foo> 
            
          Examples: name
              test  
              test 
            | foo   |
            | table |
      """
    Then the outputted JSON should be:
      """
      {
        "keyword": "Feature",
        "name": "Foo",
        "description": "one line  \nanother line  \n\n    some pre-formatted stuff",
        "line": 1,
        "elements": [
          {
            "description": "  test  \n  test",
            "keyword": "Background",
            "line": 7,
            "name": "name",
            "type": "background"
          },
          {
            "description": "  test  \n  test",
            "keyword": "Scenario",
            "line": 11,
            "name": "name",
            "type": "scenario"
          },
          {
            "description": "  test  \n  test",
            "examples": [
              {
                "description": "  test  \n  test",
                "keyword": "Examples",
                "line": 21,
                "name": "name",
                "rows": [
                  {
                    "cells": [
                      "foo"
                    ],
                    "line": 24
                  },
                  {
                    "cells": [
                      "table"
                    ],
                    "line": 25
                  }
                ]
              }
            ],
            "keyword": "Scenario Outline",
            "line": 15,
            "name": "name",
            "steps": [
              {
                "keyword": "Given ",
                "line": 19,
                "name": "<foo>"
              }
            ],
            "type": "scenario_outline"
          }
        ]
      }
      """


