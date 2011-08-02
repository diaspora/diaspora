#encoding: utf-8
require 'ap'
require 'spec_helper'
require 'gherkin/json_parser'
require 'gherkin/formatter/json_formatter'

module Gherkin
  describe JSONParser do 

    def check_json(json)
      io = StringIO.new
      f = Formatter::JSONFormatter.new(io)
      p = JSONParser.new(f, f)
      p.parse(json, 'unknown.json', 0)
      expected = JSON.parse(json)
      actual   = JSON.parse(io.string)
      actual.should == expected
    end

    it "should parse a barely empty feature" do
      check_json(%{{
        "keyword": "Feature", 
        "name": "One", 
        "description": "", 
        "line" : 3 
      }})
    end

    it "should parse feature with tags and one scenario" do
      check_json(%{{
        "tags": [
          {
            "name": "@foo",
            "line": 22
          }
        ],
        "keyword": "Feature", 
        "name": "One", 
        "description": "", 
        "line": 3,
        "elements": [
          {
            "type": "scenario",
            "steps": [
              {
                "name": "Hello",
                "multiline_arg": {
                  "type": "table",
                  "value": [
                    {
                      "cells": ["foo", "bar"]
                    }
                  ]
                }
              }
            ]
          }
        ]
      }})
    end

    it "should parse feature with match, result and embedding" do
      check_json(%{{
        "tags": [
          {
            "name": "@foo",
            "line": 22
          }
        ],
        "keyword": "Feature", 
        "name": "One", 
        "description": "", 
        "line": 3,
        "elements": [
          {
            "type": "scenario",
            "steps": [
              {
                "keyword": "Given ",
                "name": "a passing step",
                "line": 6,
                "match": {
                  "arguments": [
                    {
                      "offset": 22,
                      "val": "cukes"
                    }
                  ],
                  "location": "features/step_definitions/steps.rb:1"
                },
                "result": {
                  "status": "failed",
                  "error_message": "You suck",
                  "duration": -1
                },
                "embeddings": [
                  {
                    "mime_type": "text/plain",
                    "data": "Tm8sIEknbSBub3QgaW50ZXJlc3RlZCBpbiBkZXZlbG9waW5nIGEgcG93ZXJmdWwgYnJhaW4uIEFsbCBJJ20gYWZ0ZXIgaXMganVzdCBhIG1lZGlvY3JlIGJyYWluLCBzb21ldGhpbmcgbGlrZSB0aGUgUHJlc2lkZW50IG9mIHRoZSBBbWVyaWNhbiBUZWxlcGhvbmUgYW5kIFRlbGVncmFwaCBDb21wYW55Lg=="
                  }
                ]
              }
            ]
          }
        ]
      }})
    end

    it "shoud parse a complex feature" do
      check_json(fixture("complex.json"))
    end
  end
end
