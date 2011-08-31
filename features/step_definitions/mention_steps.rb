And /^Alice has a post mentioning Bob$/ do
  alice = User.find_by_email 'alice@alice.alice'
  bob = User.find_by_email 'bob@bob.bob'
  aspect = alice.aspects.first
  alice.post(:status_message, :text => "@{Bob Jones; #{bob.person.diaspora_handle}}", :to => alice.aspects.first)
end

When /^I fill in a mention for bob into the publisher$/ do
  bob = User.find_by_email 'bob@bob.bob'
  And 'I fill in "status_message_fake_text" with "Hi, @{Bob Jones; #{bob.person.diaspora_handle}} long time no see'
end
