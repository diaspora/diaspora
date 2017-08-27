# frozen_string_literal: true

And /^Alice has a post mentioning Bob$/ do
  alice = User.find_by_email "alice@alice.alice"
  bob = User.find_by_email "bob@bob.bob"
  aspect = alice.aspects.where(:name => "Besties").first
  alice.post(:status_message, :text => "@{Bob Jones; #{bob.person.diaspora_handle}}", :to => aspect)
end

And /^Alice has (\d+) posts mentioning Bob$/ do |n|
  n.to_i.times do
    alice = User.find_by_email "alice@alice.alice"
    bob = User.find_by_email "bob@bob.bob"
    aspect = alice.aspects.where(:name => "Besties").first
    alice.post(:status_message, :text => "@{Bob Jones; #{bob.person.diaspora_handle}}", :to => aspect)
  end
end

And /^I mention Alice in the publisher$/ do
  step %(I append "@alice" to the publisher)
  step %(I click on the first user in the mentions dropdown list)
end

And /^I click on the first user in the mentions dropdown list$/ do
  find(".tt-menu .tt-suggestion", match: :first).click
end

Then /^I should not see the mentions dropdown list$/ do
  expect(page).to have_no_css ".tt-menu"
end
