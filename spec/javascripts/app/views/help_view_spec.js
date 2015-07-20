describe("app.views.Help", function(){
  beforeEach(function(){
    this.view = new app.views.Help();
  });

  beforeEach(function(){
    Diaspora.I18n.load({"tutorials":"tutorials","tutorial":"tutorial","irc":"IRC","wiki":"wiki","markdown":"Markdown","here":"here","foundation_website":"diaspora foundation website","third_party_tools":"third party tools","getting_started_tutorial":"'Getting started' tutorial series","getting_help":{"title":"Getting help","getting_started_q":"Help! I need some basic help to get me started!","getting_started_a":"You're in luck. Try the %{tutorial_series} on our project site. It will take you step-by-step through the registration process and teach you all the basic things you need to know about using diaspora*.","get_support_q":"What if my question is not answered in this FAQ? Where else can I get support?","get_support_a_website":"visit our %{link}","get_support_a_tutorials":"check out our %{tutorials}","get_support_a_wiki":"search the %{link}","get_support_a_irc":"join us on %{irc} (Live chat)","get_support_a_hashtag":"ask in a public post on diaspora* using the %{question} hashtag"},"account_and_data_management":{"title":"Account and data management","move_pods_q":"How do I move my seed (account) from one pod to another?","move_pods_a":"In the future you will be able to export your seed from a pod and import it on another, but this is not currently possible. You could always open a new account and add your contacts to aspects on that new seed, and ask them to add your new seed to their aspects.","download_data_q":"Can I download a copy of all of my data contained in my seed (account)?","download_data_a":"Yes. At the bottom of the Account tab of your settings page there are two buttons for downloading your data.","close_account_q":"How do I delete my seed (account)?","close_account_a":"Go to the bottom of your settings page and click the Close Account button.","data_visible_to_podmin_q":"How much of my information can my pod administrator see?","data_visible_to_podmin_a":"Communication *between* pods is always encrypted (using SSL and diaspora*'s own transport encryption), but the storage of data on pods is not encrypted. If they wanted to, the database administrator for your pod (usually the person running the pod) could access all your profile data and everything that you post (as is the case for most websites that store user data). Running your own pod provides more privacy since you then control access to the database.","data_other_podmins_q":"Can the administrators of other pods see my information?","data_other_podmins_a":"Once you are sharing with someone on another pod, any posts you share with them and a copy of your profile data are stored (cached) on their pod, and are accessible to that pod's database administrator. When you delete a post or profile data it is deleted from your pod and any other pods where it had previously been stored."},"aspects":{"title":"Aspects","what_is_an_aspect_q":"What is an aspect?","what_is_an_aspect_a":"Aspects are the way you group your contacts on diaspora*. An aspect is one of the faces you show to the world. It might be who you are at work, or who you are to your family, or who you are to your friends in a club you belong to.","who_sees_post_q":"When I post to an aspect, who sees it?","who_sees_post_a":"If you make a limited post, it will only be visible the people you have put in that aspect (or those aspects, if it is made to multiple aspects). Contacts you have that aren't in the aspect have no way of seeing the post, unless you've made it public. Only public posts will ever be visible to anyone who you haven't placed into one of your aspects.","restrict_posts_i_see_q":"Can I restrict the posts I see to just those from certain aspects?","restrict_posts_i_see_a":"Yes. Click on My Aspects in the side-bar and then click individual aspects in the list to select or deselect them. Only the posts by people in the selected aspects will appear in your stream.","contacts_know_aspect_q":"Do my contacts know which aspects I have put them in?","contacts_know_aspect_a":"No. They cannot see the name of the aspect under any circumstances.","contacts_visible_q":"What does \"make contacts in this aspect visible to each other\" mean?","contacts_visible_a":"If you check this option then contacts from that aspect will be able to see who else is in it, on your profile page under your picture. It's best to select this option only if the contacts in that aspect all know each other. They still won't be able to see what the aspect is called.","remove_notification_q":"If I remove someone from an aspect, or all of my aspects, are they notified of this?","remove_notification_a":"No.","rename_aspect_q":"Can I rename an aspect?","rename_aspect_a":"Yes. In your list of aspects on the left side of the main page, point your mouse at the aspect you want to rename. Click the little 'edit' pencil that appears to the right. Click rename in the box that appears.","change_aspect_of_post_q":"Once I have posted something, can I change the aspect(s) that can see it?","change_aspect_of_post_a":"No, but you can always make a new post with the same content and post it to a different aspect.","post_multiple_aspects_q":"Can I post content to multiple aspects at once?","post_multiple_aspects_a":"Yes. When you are making a post, use the aspect selector button to select or deselect aspects. Your post will be visible to all the aspects you select. You could also select the aspects you want to post to in the side-bar. When you post, the aspect(s) that you have selected in the list on the left will automatically be selected in the aspect selector when you start to make a new post.","person_multiple_aspects_q":"Can I add a person to multiple aspects?","person_multiple_aspects_a":"Yes. Go to your contacts page and click my contacts. For each contact you can use the menu on the right to add them to (or remove them from) as many aspects as you want. Or you can add them to a new aspect (or remove them from an aspect) by clicking the aspect selector button on their profile page. Or you can even just move the pointer over their name where you see it in the stream, and a 'hover-card' will appear. You can change the aspects they are in right there.","delete_aspect_q":"How do I delete an aspect?","delete_aspect_a":"In your list of aspects on the left side of the main page, point your mouse at the aspect you want to delete. Click the little 'edit' pencil that appears on the right. Click the delete button in the box that appears."},"mentions":{"title":"Mentions","what_is_a_mention_q":"What is a \"mention\"?","what_is_a_mention_a":"A mention is a link to a person's profile page that appears in a post. When someone is mentioned they receive a notification that calls their attention to the post.","how_to_mention_q":"How do I mention someone when making a post?","how_to_mention_a":"Type the \"@\" sign and start typing their name. A drop down menu should appear to let you select them more easily. Note that it is only possible to mention people you have added to an aspect.","mention_in_comment_q":"Can I mention someone in a comment?","mention_in_comment_a":"No, not currently.","see_mentions_q":"Is there a way to see the posts in which I have been mentioned?","see_mentions_a":"Yes, click \"Mentions\" in the left hand column on your home page."},"pods":{"title":"Pods","what_is_a_pod_q":"What is a pod?","what_is_a_pod_a":"A pod is a server running the diaspora* software and connected to the diaspora* network. \"Pod\" is a metaphor referring to pods on plants which contain seeds, in the way that a server contains a number of user accounts. There are many different pods. You can add friends from other pods and communicate with them. (You can think of a diaspora* pod as similar to an email provider: there are public pods, private pods, and with some effort you can even run your own).","find_people_q":"I just joined a pod, how can I find people to share with?","find_people_a":"Invite your friends using the email link in the side-bar. Follow #tags to discover others who share your interests, and add those who post things that interest you to an aspect. Shout out that you're #newhere in a public post.","use_search_box_q":"How do I use the search box to find particular individuals?","use_search_box_a":"If you know their full diaspora* ID (e.g. username@podname.org), you can find them by searching for it. If you are on the same pod you can search for just their username. An alternative is to search for them by their profile name (the name you see on screen). If a search does not work the first time, try it again."},"posts_and_posting":{"title":"Posts and posting","hide_posts_q":"How do I hide a post? / How do I stop getting notifications about a post that I commented on?","hide_posts_a":"If you point your mouse at the top of a post, an X appears on the right. Click it to hide the post and mute notifications about it. You can still see the post if you visit the profile page of the person who posted it.","format_text_q":"How can I format the text in my posts (bold, italics, etc.)?","format_text_a":"By using a simplified system called %{markdown}. You can find the full Markdown syntax %{here}. The preview button is really helpful here, as you can see how your message will look before you share it.","insert_images_q":"How do I insert images into posts?","insert_images_a":"Click the little camera icon to insert an image into a post. Press the photo icon again to add another photo, or you can select multiple photos to upload in one go.","insert_images_comments_q":"Can I insert images into comments?","insert_images_comments_a1":"The following Markdown code","image_text":"image text","image_url":"image url","insert_images_comments_a2":"can be used to insert images from the web into comments as well as posts.","size_of_images_q":"Can I customize the size of images in posts or comments?","size_of_images_a":"No. Images are resized automatically to fit the stream. Markdown does not have a code for specifying the size of an image.","embed_multimedia_q":"How do I embed a video, audio, or other multimedia content into a post?","embed_multimedia_a":"You can usually just paste the URL (e.g. http://www.youtube.com/watch?v=nnnnnnnnnnn ) into your post and the video or audio will be embedded automatically. Some of the sites that are supported are: YouTube, Vimeo, SoundCloud, Flickr and a few more. diaspora* uses oEmbed for this feature. We're supporting new sites all the time. Remember to always post simple, full links: no shortened links; no operators after the base URL; and give it a little time before you refresh the page after posting for seeing the preview.","character_limit_q":"What is the character limit for posts?","character_limit_a":"65,535 characters. That's 65,395 more characters than you get on Twitter! ;)","char_limit_services_q":"What is the character limit for posts shared through a connected service with a smaller character count?","char_limit_services_a":"In that case your post is limited to the smaller character count (140 in the case of Twitter; 1000 in the case of Tumblr), and the number of characters you have left to use is displayed when that service's icon is highlighted. You can still post to these services if your post is longer than their limit, but the text is truncated on those services.","stream_full_of_posts_q":"Why is my stream full of posts from people I don't know and don't share with?","stream_full_of_posts_a1":"Your stream is made up of three types of posts:","stream_full_of_posts_li1":"Posts by people you are sharing with, which come in two types: public posts and limited posts shared with an aspect that you are part of. To remove these posts from your stream, simply stop sharing with the person.","stream_full_of_posts_li2":"Public posts containing one of the tags that you follow. To remove these, stop following the tag.","stream_full_of_posts_li3":"Public posts by people listed in the Community Spotlight. These can be removed by unchecking the “Show Community Spotlight in Stream?” option in the Account tab of your Settings."},"private_posts":{"title":"Private posts","who_sees_post_q":"When I post a message to an aspect (i.e., a private post), who can see it?","who_sees_post_a":"Only logged-in diaspora* users you have placed in that aspect can see your private post.","can_comment_q":"Who can comment on or like my private post?","can_comment_a":"Only logged-in diaspora* users you have placed in that aspect can comment on or like your private post.","can_reshare_q":"Who can reshare my private post?","can_reshare_a":"Nobody. Private posts are not resharable. Logged-in diaspora* users in that aspect can potentially copy and paste it, however.","see_comment_q":"When I comment on or like a private post, who can see it?","see_comment_a":"Only the people that the post was shared with (the people who are in the aspects selected by the original poster) can see its comments and likes. "},"private_profiles":{"title":"Private profiles","who_sees_profile_q":"Who sees my private profile?","who_sees_profile_a":"Any logged-in user that you are sharing with (meaning, you have added them to one of your aspects). However, people following you, but whom you do not follow, will see only your public information.","whats_in_profile_q":"What's in my private profile?","whats_in_profile_a":"Biography, location, gender, and birthday. It's the stuff in the bottom section of the edit profile page. All this information is optional – it's up to you whether you fill it in. Logged-in users who you have added to your aspects are the only people who can see your private profile. They will also see the private posts that made to the aspect(s) they are in, mixed in with your public posts, when they visit your profile page.","who_sees_updates_q":"Who sees updates to my private profile?","who_sees_updates_a":"Anyone in your aspects sees changes to your private profile. "},"public_posts":{"title":"Public posts","who_sees_post_q":"When I post something publicly, who can see it?","who_sees_post_a":"Anyone using the internet can potentially see a post you mark public, so make sure you really do want your post to be public. It's a great way of reaching out to the world.","find_public_post_q":"How can other people find my public post?","find_public_post_a":"Your public posts will appear in the streams of anyone following you. If you included #tags in your public post, anyone following those tags will find your post in their streams. Every public post also has a specific URL that anyone can view, even if they're not logged in - thus public posts may be linked to directly from Twitter, blogs, etc. Public posts may also be indexed by search engines.","can_comment_reshare_like_q":"Who can comment on, reshare, or like my public post?","can_comment_reshare_like_a":"Any logged-in diaspora* user can comment on, reshare, or like your public post.","see_comment_reshare_like_q":"When I comment on, reshare, or like a public post, who can see it?","see_comment_reshare_like_a":"Any logged-in diaspora* user and anyone else on the internet. Comments, likes, and reshares of public posts are also public.","deselect_aspect_posting_q":"What happens when I deselect one or more aspects when making a public post?","deselect_aspect_posting_a":"Deselecting aspects does not affect a public post. It will still appear in the streams of all of your contacts. To make a post visible only to specific aspects, you need to select those aspects from the button under the publisher."},"public_profiles":{"title":"Public profiles","who_sees_profile_q":"Who sees my public profile?","who_sees_profile_a":"Any logged-in diaspora* user, as well as the wider internet, can see it. Each profile has a direct URL, so it may be linked to directly from outside sites. It may be indexed by search engines.","whats_in_profile_q":"What's in my public profile","whats_in_profile_a":"Your name, the five tags you chose to describe yourself, and your photo. It's the stuff in the top section of the edit profile page. You can make this profile information as identifiable or anonymous as you like. Your profile page also shows any public posts you have made.","who_sees_updates_q":"Who sees updates to my public profile?","who_sees_updates_a":"Anyone can see changes if they visit your profile page.","what_do_tags_do_q":"What do the tags on my public profile do?","what_do_tags_do_a":"They help people get to know you. Your profile picture will also appear on the left-hand side of those particular tag pages, along with anyone else who has them in their public profile."},"resharing_posts":{"title":"Resharing posts","reshare_public_post_aspects_q":"Can I reshare a public post with only certain aspects?","reshare_public_post_aspects_a":"No, when you reshare a public post it automatically becomes one of your public posts. To share it with certain aspects, copy and paste the contents of the post into a new post.","reshare_private_post_aspects_q":"Can I reshare a private post with only certain aspects?","reshare_private_post_aspects_a":"No, it is not possible to reshare a private post. This is to respect the intentions of the original poster who only shared it with a particular group of people."},"sharing":{"title":"Sharing","add_to_aspect_q":"What happens when I add someone to one of my aspects? Or when someone adds me to one of their aspects?","add_to_aspect_a1":"Let's say that Amy adds Ben to an aspect, but Ben has not (yet) added Amy to an aspect:","add_to_aspect_li1":"Ben will receive a notification that Amy has \"started sharing\" with Ben.","add_to_aspect_li2":"Amy will start to see Ben's public posts in her stream.","add_to_aspect_li3":"Amy will not see any of Ben's private posts.","add_to_aspect_li4":"Ben will not see Amy's public or private posts in his stream.","add_to_aspect_li5":"But if Ben goes to Amy's profile page, then he will see Amy's private posts that she makes to her aspect that has him in it (as well as her public posts which anyone can see there).","add_to_aspect_li6":"Ben will be able to see Amy's private profile (bio, location, gender, birthday).","add_to_aspect_li7":"Amy will appear under \"Only sharing with me\" on Ben's contacts page.","add_to_aspect_a2":"This is known as asymmetrical sharing. If and when Ben also adds Amy to an aspect then it would become mutual sharing, with both Amy's and Ben's public posts and relevant private posts appearing in each other's streams, etc. ","only_sharing_q":"Who are the people listed in \"Only sharing with me\" on my contacts page?","only_sharing_a":"These are people that have added you to one of their aspects, but who are not (yet) in any of your aspects. In other words, they are sharing with you, but you are not sharing with them (asymmetrical sharing). If you add them to an aspect, they will then appear under that aspect and not under \"only sharing with you\". See above.","list_not_sharing_q":"Is there a list of people whom I have added to one of my aspects, but who have not added me to one of theirs?","list_not_sharing_a":"No, but you can see whether or not someone is sharing with you by visiting their profile page. If they are, the bar under their profile picture will be green; if not, it'll be grey. You should get a notification each time someone starts sharing with you.","see_old_posts_q":"When I add someone to an aspect, can they see older posts that I have already posted to that aspect?","see_old_posts_a":"No. They will only be able to see new posts to that aspect. They (and everyone else) can see your older public posts on your profile page, and they may also see them in their stream."},"tags":{"title":"Tags","what_are_tags_for_q":"What are tags for?","what_are_tags_for_a":"Tags are a way to categorize a post, usually by topic. Searching for a tag shows all posts with that tag that you can see (both public and private posts). This lets people who are interested in a given topic find public posts about it.","tags_in_comments_q":"Can I put tags in comments or just in posts?","tags_in_comments_a":"A tag added to a comment will still appear as a link to that tag's page, but it will not make that post (or comment) appear on that tag page. This only works for tags in posts.","followed_tags_q":"What are \"#Followed Tags\" and how do I follow a tag?","followed_tags_a":"After searching for a tag you can click the button at the top of the tag's page to \"follow\" that tag. It will then appear in your list of followed tags on the left. Clicking one of your followed tags takes you to that tag's page so you can see recent posts containing that tag. Click on #Followed Tags to see a stream of posts that include one of any of your followed tags. ","people_tag_page_q":"Who are the people listed on the left-hand side of a tag page?","people_tag_page_a":"They are people who have listed that tag to describe themselves in their public profile.","filter_tags_q":"How can I filter/exclude some tags from my stream?","filter_tags_a":"This is not yet available directly through diaspora*, but some %{third_party_tools} have been written that might provide this."},"miscellaneous":{"title":"Miscellaneous","back_to_top_q":"Is there a quick way to go back to the top of a page after I scroll down?","back_to_top_a":"Yes. After scrolling down a page, click on the grey arrow that appears in the bottom right corner of your browser window.","photo_albums_q":"Are there photo or video albums?","photo_albums_a":"No, not currently. However you can view a stream of their uploaded pictures from the Photos section in the side-bar of their profile page.","subscribe_feed_q":"Can I subscribe to someone's public posts with a feed reader?","subscribe_feed_a":"Yes, but this is still not a polished feature and the formatting of the results is still pretty rough. If you want to try it anyway, go to someone's profile page and click the feed button in your browser, or you can copy the profile URL (i.e. https://joindiaspora.com/people/somenumber), and paste it into a feed reader. The resulting feed address looks like this: https://joindiaspora.com/public/username.atom Diaspora uses Atom rather than RSS.","diaspora_app_q":"Is there a diaspora* app for Android or iOS?","diaspora_app_a":"There are several Android apps in very early development. Several are long-abandoned projects and so do not work well with the current version of diaspora*. Don't expect much from these apps at the moment. Currently the best way to access diaspora* from your mobile device is through a browser, because we've designed a mobile version of the site which should work well on all devices. There is currently no app for iOS. Again, diaspora* should work fine via your browser."}}, "en");
    Diaspora.Page = "HelpFaq";
  });

  describe("render", function(){
    beforeEach(function(){
      this.view.render();
    });

    it('should initially show getting help section', function(){
      expect(this.view.$el.find('#faq').children().first().data('template')).toBe('faq_getting_help');
    });

    it('should show account and data management section', function(){
      this.view.$el.find('a[data-section=account_and_data_management]').trigger('click');
      expect(this.view.$el.find('#faq').children().first().hasClass('faq_question_account_and_data_management')).toBeTruthy();
    });

    it('should show aspects section', function(){
      this.view.$el.find('a[data-section=aspects]').trigger('click');
      expect(this.view.$el.find('#faq').children().first().hasClass('faq_question_aspects')).toBeTruthy();
    });

    it('should show mentions section', function(){
      this.view.$el.find('a[data-section=mentions]').trigger('click');
      expect(this.view.$el.find('#faq').children().first().hasClass('faq_question_mentions')).toBeTruthy();
    });

    it('should show pods section', function(){
      this.view.$el.find('a[data-section=pods]').trigger('click');
      expect(this.view.$el.find('#faq').children().first().hasClass('faq_question_pods')).toBeTruthy();
    });

    it('should show posts and posting section', function(){
      this.view.$el.find('a[data-section=posts_and_posting]').trigger('click');
      expect(this.view.$el.find('#faq').children().first().data('template')).toBe('faq_posts_and_posting');
    });

    it('should show private posts section', function(){
      this.view.$el.find('a[data-section=private_posts]').trigger('click');
      expect(this.view.$el.find('#faq').children().first().hasClass('faq_question_private_posts')).toBeTruthy();
    });

    it('should show private profiles section', function(){
      this.view.$el.find('a[data-section=private_profiles]').trigger('click');
      expect(this.view.$el.find('#faq').children().first().hasClass('faq_question_private_profiles')).toBeTruthy();
    });

    it('should show public posts section', function(){
      this.view.$el.find('a[data-section=public_posts]').trigger('click');
      expect(this.view.$el.find('#faq').children().first().hasClass('faq_question_public_posts')).toBeTruthy();
    });

    it('should show public profiles section', function(){
      this.view.$el.find('a[data-section=public_profiles]').trigger('click');
      expect(this.view.$el.find('#faq').children().first().hasClass('faq_question_public_profiles')).toBeTruthy();
    });

    it('should show resharing posts section', function(){
      this.view.$el.find('a[data-section=resharing_posts]').trigger('click');
      expect(this.view.$el.find('#faq').children().first().hasClass('faq_question_resharing_posts')).toBeTruthy();
    });

    it('should show sharing section', function(){
      this.view.$el.find('a[data-section=sharing]').trigger('click');
      expect(this.view.$el.find('#faq').children().first().data('template')).toBe('faq_sharing');
    });

    it('should show tags section', function(){
      this.view.$el.find('a[data-section=tags]').trigger('click');
      expect(this.view.$el.find('#faq').children().first().data('template')).toBe('faq_tags');
    });

    it('should show keyboard shortcuts section', function(){
      this.view.$el.find('a[data-section=keyboard_shortcuts]').trigger('click');
      expect(this.view.$el.find('#faq').children().first().data('template')).toBe('faq_keyboard_shortcuts');
    });

    it('should show miscellaneous section', function(){
      this.view.$el.find('a[data-section=miscellaneous]').trigger('click');
      expect(this.view.$el.find('#faq').children().first().hasClass('faq_question_miscellaneous')).toBeTruthy();
    });
  });

  describe("findSection", function() {
    beforeEach(function() {
      this.view.render();
    });

    it('should return null for an unknown section', function() {
      expect(this.view.findSection('you_shall_not_pass')).toBeNull();
    });

    it('should return the correct section link for existing sections', function() {
      var sections = [
        'account_and_data_management',
        'aspects',
        'pods',
        'keyboard_shortcuts',
        'tags',
        'miscellaneous'
      ];

      var self = this;
      _.each(sections, function(section) {
        var el = self.view.$el.find('a[data-section=' + section + ']');
        expect(self.view.findSection(section).html()).toBe(el.html());
      });
    });
  });

  describe("menuClicked", function() {
    beforeEach(function() {
      this.view.render();
    });

    it('should rewrite the location', function(){
      var sections = [
        'account_and_data_management',
        'miscellaneous'
      ];
      spyOn(app.router, 'navigate');

      var self = this;
      _.each(sections, function(section) {
        self.view.$el.find('a[data-section=' + section + ']').trigger('click');
        expect(app.router.navigate).toHaveBeenCalledWith('help/' + section);
      });
    });
  });

  describe("chat section", function(){
    describe("chat enabled", function(){
      beforeEach(function(){
        gon.chatEnabled = true;
        this.view = new app.views.Help();
        this.view.render();
      });

      it('should display the chat', function(){
        expect(this.view.$el.find('a[data-section=chat]').length).toBe(1);
      });
    });

    describe("chat disabled", function(){
      beforeEach(function(){
        gon.chatEnabled = false;
        this.view = new app.views.Help();
        this.view.render();
      });

      it('should not display the chat', function () {
        expect(this.view.$el.find('a[data-section=chat]').length).toBe(0);
      });
    });
  });
});
