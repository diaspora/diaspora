When /^I filter notifications by likes$/ do
  step %(I follow "Liked" within "#notifications_container ul.nav.nav-tabs")
end

When /^I filter notifications by mentions$/ do
  step %(I follow "Mentioned" within "#notifications_container ul.nav.nav-tabs")
end
