 
When /^(?:|I )select a birthday "([^"]*)" years ago$/ do |age|
  time = age.to_i.years.ago
  with_scope("#update_profile_form") do
    select(time.day.to_s,   :from => "profile_date_day")
    select(time.strftime("%B"), :from => "profile_date_month")
    select(time.year.to_s,  :from => "profile_date_year")
  end
end

Then /^(?:|I )should see the age "([^"]*)"$/ do |age|
  with_scope("#profile_information") do
    page.should have_xpath('//*', :text => age)
  end
end
