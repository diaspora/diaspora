# frozen_string_literal: true

Then /^I should see a HTML5 (video|audio) player$/ do |type|
  find(".post-content .media-embed")
  find(".stream-container").should have_css(".post-content .media-embed #{type}")
end
