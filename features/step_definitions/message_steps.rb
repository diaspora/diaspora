# frozen_string_literal: true

Then /^I should see the "(.*)" message$/ do |message|
  text = case message
           when "alice is excited"
             @alice ||= FactoryGirl.create(:user, :username => "Alice")
             I18n.translate('invitation_codes.excited', :name => @alice.name)
           when "welcome to diaspora"
             I18n.translate('users.getting_started.well_hello_there')
           else
             raise "muriel, you don't have that message key, add one here"
           end

  page.should have_content(text)
end
