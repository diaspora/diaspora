require "spec_helper"

describe "template generation" do
  it "generates templates", :fixture => true do
    extend JasmineFixtureGeneration
    templates = Haml::Engine.new(Rails.root.join("app", "views", "layouts", "_templates.haml").read).render
    save_fixture(templates, "underscore_templates")
  end
end
