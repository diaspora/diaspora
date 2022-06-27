# frozen_string_literal: true

require "spec_helper"

def confirm_api_error(response, code, message)
  expect(response.status).to eq(code)
  expect(JSON.parse(response.body)).to eq("code" => code, "message" => message)
end

def expect_to_match_json_schema(json, fragment)
  errors = JSON::Validator.fully_validate("lib/schemas/api_v1.json", json, fragment: fragment)
  expect(errors).to be_empty
end
