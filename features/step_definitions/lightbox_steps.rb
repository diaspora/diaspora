Then 'I should see the photo lightbox' do
  Then %{I should see a "img" within "#lightbox-imageset"}
  And %{I should see a "#lightbox-backdrop" within "body"}
  And %{I should see a "#lightbox-image" within "body"}
end

Then 'I should not see the photo lightbox' do
  Then %{I should not see a "img" within "#lightbox-imageset"}
  And %{I should not see a "#lightbox-backdrop" within "body"}
  And %{I should not see a "#lightbox-image" within "body"}
end

Then 'I press the close lightbox link' do
  find(:css, "#lightbox-close-link").click
end

Then 'I press the lightbox backdrop' do
  find(:css, "#lightbox-backdrop").click
end