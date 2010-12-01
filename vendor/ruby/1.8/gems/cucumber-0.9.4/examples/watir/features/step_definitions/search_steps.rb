# Full Watir API: http://wtr.rubyforge.org/rdoc/
# Full RSpec API: http://rspec.rubyforge.org/

Given 'I am on the Google search page' do
  @browser.goto 'http://www.google.com/'
end

When /I search for "(.*)"/ do |query|
  @browser.text_field(:name, 'q').set(query)
  @browser.button(:name, 'btnG').click
end

Then /I should see/ do |text|
  @browser.text.should =~ /#{text}/m
end

# To avoid step definitions that are tightly coupled to your user interface,
# consider creating classes for your pages - such as this:
# http://github.com/aslakhellesoy/cucumber/tree/v0.1.15/examples/watir/features/step_definitons/search_steps.rb
#
# You may keep the page classes along your steps, or even better, put them in separate files, e.g.
# support/pages/google_search.rb
#
# This technique is called "Page Objects", and you can read more about it here:
# http://github.com/marekj/watirloo/tree/master
# We're not using this technique here, since we want to illustrate the basics only.