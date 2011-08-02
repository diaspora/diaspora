RSpec::Matchers.define :have_files do |expected_files|
  match do |rails_app|
    actual_files = rails_app.files
    @missing_files = expected_files - actual_files
    @missing_files.empty?
  end

  failure_message_for_should do |expected_files|
    "Rails app was missing these files:\n" + @missing_files.map { |file| "  #{file}" }.join("\n")
  end
end

RSpec::Matchers.define :have_contents do |contents|
  match do |file|
    file.read.include?(contents)
  end
end
