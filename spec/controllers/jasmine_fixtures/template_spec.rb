require "spec_helper"

describe "template generation" do
  it "generates templates" do
    extend JasmineFixtureGeneration
    templates = Haml::Engine.new(Rails.root.join("app", "views", "templates", "_templates.haml").read).render
    save_fixture(templates, "underscore_templates")
  end
end
