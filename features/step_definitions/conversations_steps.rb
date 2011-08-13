Then /^"([^"]*)" should be part of active conversation$/ do |name|
  within(".conversation_participants") do
    find("img.avatar[title^='#{name} ']").should_not be_nil
  end
end
