# frozen_string_literal: true

When(/^I unfollow the "(.*?)" tag$/) do |tag|
  accept_alert do
    within("#tags_list") do
      li = find("li", text: tag)
      li.hover
      li.find(".delete-tag-following").click
    end
  end
end

When /^I follow the "(.*?)" tag$/ do |tag|
  TagFollowing.create!(tag: FactoryGirl.create(:tag, name: tag), user: @me)
end
