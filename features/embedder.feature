# @javascript
# Feature: embedding
#     Get sure that embedding stuff actually works
# 
#     Background:
#       Given a user with username "bob"
#       When I sign in as "bob@bob.bob"
#       And I have no open aspects saved
#       And I am on the home page
# 
#     Scenario: Youtube is fully embedded
#       Given I expand the publisher
#       When I fill in "status_message_fake_text" with "Look at this awesome video: https://www.youtube.com/watch?v=53tq9g35kwk"
#         And I press "Share"
#         And I follow "All Aspects"
#       Then I should see "Look at this awesome video: Youtube: Leekspin" within ".stream_element"
#       When I follow "Youtube: Leekspin"
#       And I wait for the ajax to finish
#       Then I should see "Watch this video on YouTube" within ".video-container"
# 
#       #After ajax aspect switch
#       When I follow "Besties" 
#       And I wait for the ajax to finish
#       And I follow "Youtube: Leekspin"
#       Then I should see "Watch this video on YouTube" within ".video-container"
