# frozen_string_literal: true

Then "I should see the photo lightbox" do
  step %(I should see a "#blueimp-gallery" within "body")
end

Then "I should not see the photo lightbox" do
  step %(I should not see a "#blueimp-gallery" within "body")
end

Then "I press the close lightbox link" do
  find(:css, "#blueimp-gallery .close").click
end
