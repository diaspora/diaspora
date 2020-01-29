# frozen_string_literal: true

require "spec_helper"

def confirm_api_error(response, code, message)
  expect(response.status).to eq(code)
  expect(JSON.parse(response.body)).to eq("code" => code, "message" => message)
end
