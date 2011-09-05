And /^Alice has a post mentioning Bob$/ do
  alice = User.find_by_email 'alice@alice.alice'
  bob = User.find_by_email 'bob@bob.bob'
  aspect = alice.aspects.where(:name => "Besties").first
  alice.post(:status_message, :text => "@{Bob Jones; #{bob.person.diaspora_handle}}", :to => aspect)
end