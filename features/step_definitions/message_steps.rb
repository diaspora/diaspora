Then /^I should see the "(.*)" message$/ do |message|
  text = case message
           when "alice is excited"
             @alice ||= Factory(:user, :username => "Alice")
             I18n.translate('invitation_codes.excited', :name => @alice.name)
           when "welcome to diaspora"
             I18n.translate('users.getting_started.well_hello_there')
           when 'you are safe for work'
             I18n.translate('profiles.edit.you_are_safe_for_work')
           when 'you are nsfw'
             I18n.translate('profiles.edit.you_are_nsfw')
           else
             raise "muriel, you don't have that message key, add one here"
         end
  page.should have_content(text)
end