# frozen_string_literal: true

guard :rspec, cmd: "bin/spring rspec", all_on_start: false, all_after_pass: false do
  watch(/^spec\/.+_spec\.rb$/)
  watch(/^lib\/(.+)\.rb$/)       {|m| "spec/lib/#{m[1]}_spec.rb" }
  watch(/spec\/spec_helper.rb/)  { "spec" }

  # Rails example
  watch(/^spec\/.+_spec\.rb$/)
  watch(/^app\/(.+)\.rb$/)                            {|m| "spec/#{m[1]}_spec.rb" }
  watch(/^lib\/(.+)\.rb$/)                            {|m| "spec/lib/#{m[1]}_spec.rb" }
  watch(%r{^app/controllers/(.+)_(controller)\.rb$}) {|m|
    ["spec/routing/#{m[1]}_routing_spec.rb",
     "spec/#{m[2]}s/#{m[1]}_#{m[2]}_spec.rb",
     "spec/acceptance/#{m[1]}_spec.rb"]
  }
  watch(%r{^spec/support/(.+)\.rb$})                  { "spec" }
  watch("spec/spec_helper.rb")                        { "spec" }
  watch("config/routes.rb")                           { "spec/routing" }
  watch("app/controllers/application_controller.rb")  { "spec/controllers" }

  # Capybara request specs
  watch(%r{^app/views/(.+)/.*\.(erb|haml)$})          {|m| "spec/requests/#{m[1]}_spec.rb" }
end

guard :rubocop, all_on_start: false, keep_failed: false do
  watch(/(?:app|config|db|lib|features|spec)\/.+\.rb$/)
  watch(/(config.ru|Gemfile|Guardfile|Rakefile)$/)
end
