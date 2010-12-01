require "test_helper"

class BaseTest < Test::Unit::TestCase
  context "base" do
    setup do
      oauth = Twitter::OAuth.new("token", "secret")
      @access_token = OAuth::AccessToken.new(oauth.consumer, "atoken", "asecret")
      oauth.stubs(:access_token).returns(@access_token)
      @twitter = Twitter::Base.new(oauth)
    end

    context "initialize" do
      should "require a client" do
        assert_respond_to @twitter.client, :get
        assert_respond_to @twitter.client, :post
      end
    end

    should "delegate get to the client" do
      @access_token.expects(:get).with("/foo").returns(nil)
      @twitter.get("/foo")
    end

    should "delegate post to the client" do
      @access_token.expects(:post).with("/foo", {:bar => "baz"}).returns(nil)
      @twitter.post("/foo", {:bar => "baz"})
    end

    context "hitting the api" do
      should "be able to get home timeline" do
        stub_get("/1/statuses/home_timeline.json", "home_timeline.json")
        timeline = @twitter.home_timeline
        assert_equal 20, timeline.size
        first = timeline.first
        assert_equal '<a href="http://www.atebits.com/software/tweetie/">Tweetie</a>', first.source
        assert_equal 'John Nunemaker', first.user.name
        assert_equal 'http://railstips.org/about', first.user.url
        assert_equal 1441588944, first.id
        assert !first.favorited
      end

      should "be able to get friends timeline" do
        stub_get("/1/statuses/friends_timeline.json", "friends_timeline.json")
        timeline = @twitter.friends_timeline
        assert_equal 20, timeline.size
        first = timeline.first
        assert_equal '<a href="http://www.atebits.com/software/tweetie/">Tweetie</a>', first.source
        assert_equal 'John Nunemaker', first.user.name
        assert_equal 'http://railstips.org/about', first.user.url
        assert_equal 1441588944, first.id
        assert !first.favorited
      end

      should "be able to get user timeline" do
        stub_get("/1/statuses/user_timeline.json", "user_timeline.json")
        timeline = @twitter.user_timeline
        assert_equal 20, timeline.size
        first = timeline.first
        assert_equal 'Colder out today than expected. Headed to the Beanery for some morning wakeup drink. Latte or coffee...hmmm...', first.text
        assert_equal 'John Nunemaker', first.user.name
      end

      should "be able to get a status" do
        stub_get("/1/statuses/show/1441588944.json", "status.json")
        status = @twitter.status(1441588944)
        assert_equal 'John Nunemaker', status.user.name
        assert_equal 1441588944, status.id
      end

      should "be able to update status" do
        stub_post("/1/statuses/update.json", "status.json")
        status = @twitter.update("Rob Dyrdek is the funniest man alive. That is all.")
        assert_equal 'John Nunemaker', status.user.name
        assert_equal 'Rob Dyrdek is the funniest man alive. That is all.', status.text
      end

      should "be able to retweet a status" do
        stub_post("/1/statuses/retweet/6235127466.json", "retweet.json")
        status = @twitter.retweet(6235127466)
        assert_equal 'Michael D. Ivey', status.user.name
        assert_equal "RT @jstetser: I'm not actually awake. My mind's on autopilot for food and I managed to take a detour along the way.", status.text
        assert_equal 'jstetser', status.retweeted_status.user.screen_name
        assert_equal "I'm not actually awake. My mind's on autopilot for food and I managed to take a detour along the way.", status.retweeted_status.text
      end

      should "be able to get retweets of a status" do
        stub_get("/1/statuses/retweets/6192831130.json", "retweets.json")
        retweets = @twitter.retweets(6192831130)
        assert_equal 6, retweets.size
        first = retweets.first
        assert_equal 'josephholsten', first.user.name
        assert_equal "RT @Moltz: Personally, I won't be satisfied until a Buddhist monk lights himself on fire for web standards.", first.text
      end

      should "be able to get mentions" do
        stub_get("/1/statuses/mentions.json", "mentions.json")
        mentions = @twitter.mentions
        assert_equal 19, mentions.size
        first = mentions.first
        assert_equal "-oAk-", first.user.name
        assert_equal "@jnunemaker cold out today. cold yesterday. even colder today.", first.text
      end

      should "be able to get retweets by me" do
        stub_get("/1/statuses/retweeted_by_me.json", "retweeted_by_me.json")
        retweeted_by_me = @twitter.retweeted_by_me
        assert_equal 20, retweeted_by_me.size
        first = retweeted_by_me.first.retweeted_status
        assert_equal 'Troy Davis', first.user.name
        assert_equal "I'm the mayor of win a free MacBook Pro with promo code Cyber Monday RT for a good time", first.text
      end

      should "be able to get retweets to me" do
        stub_get("/1/statuses/retweeted_to_me.json", "retweeted_to_me.json")
        retweeted_to_me = @twitter.retweeted_to_me
        assert_equal 20, retweeted_to_me.size
        first = retweeted_to_me.first.retweeted_status
        assert_equal 'Cloudvox', first.user.name
        assert_equal "Testing counts with voice apps too:\n\"the voice told residents to dial 'nine hundred eleven' rather than '9-1-1'\" http://j.mp/7mqe2B", first.text
      end

      should "be able to get retweets of me" do
        stub_get("/1/statuses/retweets_of_me.json", "retweets_of_me.json")
        retweets_of_me = @twitter.retweets_of_me
        assert_equal 11, retweets_of_me.size
        first = retweets_of_me.first
        assert_equal 'Michael D. Ivey', first.user.name
        assert_equal "Trying out geotweets in Birdfeed. No \"new RT\" support, though. Any iPhone client with RTs yet?", first.text
      end

      should "be able to get users who retweeted a tweet" do
        stub_get("/1/statuses/9021932472/retweeted_by.json", "retweeters_of_tweet.json")
        retweeters = @twitter.retweeters_of("9021932472")
        assert_equal 4, retweeters.size
        first = retweeters.first
        assert_equal 'bryanl', first.screen_name
      end

      should "be able to get ids of users who retweeted a tweet" do
        stub_get("/1/statuses/9021932472/retweeted_by/ids.json", "ids.json")
        retweeters = @twitter.retweeters_of("9021932472", :ids_only => true)
        assert_equal 61940910, retweeters.first
      end

      should "be able to get follower ids" do
        stub_get("/1/followers/ids.json", "follower_ids.json")
        follower_ids = @twitter.follower_ids
        assert_equal 1252, follower_ids.size
        assert_equal 613, follower_ids.first
      end

      should "be able to get friend ids" do
        stub_get("/1/friends/ids.json", "friend_ids.json")
        friend_ids = @twitter.friend_ids
        assert_equal 161, friend_ids.size
        assert_equal 15323, friend_ids.first
      end

      should "be able to test whether a friendship exists" do
        stub_get("/1/friendships/exists.json?user_a=pengwynn&user_b=sferik", "friendship_exists.json")
        assert @twitter.friendship_exists?("pengwynn", "sferik")
      end

      should "be able to get a friendship" do
        stub_get("/1/friendships/show.json?source_screen_name=dcrec1&target_screen_name=pengwynn", "friendship.json")
        assert !@twitter.friendship_show(:source_screen_name => "dcrec1", :target_screen_name => "pengwynn").relationship.target.followed_by
      end

      should "be able to lookup a user by id" do
        stub_get("/1/users/show.json?user_id=4243", "user.json")
        user = @twitter.user(4243)
        assert_equal 'jnunemaker', user.screen_name
      end

      should "be able to lookup a user by screen_name" do
        stub_get("/1/users/show.json?screen_name=jnunemaker", "user.json")
        user = @twitter.user('jnunemaker')
        assert_equal 'jnunemaker', user.screen_name
      end

      should "be able to lookup users in bulk" do
        stub_get("/1/users/lookup.json?screen_name=sferik&user_id=59593,774010", "users.json")
        users = @twitter.users("sferik", 59593, 774010)
        assert_equal 3, users.count
        screen_names = users.map{|user| user["screen_name"]}
        assert screen_names.include? "sferik"
        assert screen_names.include? "jm3"
        assert screen_names.include? "jamiew"
      end

      should "be able to search people" do
        stub_get("/1/users/search.json?q=Wynn%20Netherland", "people_search.json")
        people = @twitter.user_search("Wynn Netherland")
        assert_equal 'pengwynn', people.first.screen_name
      end

      should "be able to get followers' stauses" do
        stub_get("/1/statuses/followers.json", "followers.json")
        assert @twitter.followers
      end

      should "be able to get blocked users' IDs" do
        stub_get("/1/blocks/blocking/ids.json", "ids.json")
        assert @twitter.blocked_ids
      end

      should "be able to get an array of blocked users" do
        stub_get("/1/blocks/blocking.json", "blocking.json")
        blocked = @twitter.blocking
        assert_equal 'euciavkvyplx', blocked.last.screen_name
      end

      should "report a spammer" do
        stub_post("/1/report_spam.json", "report_spam.json")
        spammer = @twitter.report_spam(:screen_name => 'lucaasvaz00')
        assert_equal 'lucaasvaz00', spammer.screen_name
      end

      should "upload a profile image" do
        stub_post("/1/account/update_profile_image.json", "update_profile_image.json")
        user = @twitter.update_profile_image(File.new(sample_image("sample-image.png")))
        assert_equal 'John Nunemaker', user.name # update_profile_image responds with the user
      end

      should "upload a background image" do
        stub_post("/1/account/update_profile_background_image.json", "update_profile_background_image.json")
        user = @twitter.update_profile_background(File.new(sample_image("sample-image.png")))
        assert_equal 'John Nunemaker', user.name # update_profile_background responds with the user
      end
    end
    
    context "when using saved searches" do
      should "be able to retrieve my saved searches" do
        stub_get("/1/saved_searches.json", "saved_searches.json")
        searches = @twitter.saved_searches
        assert_equal 'great danes', searches[0].query
        assert_equal 'rubyconf OR railsconf', searches[1].query
      end
      
      should "be able to retrieve a saved search by id" do
        stub_get("/1/saved_searches/show/7095598.json", "saved_search.json")
        search = @twitter.saved_search(7095598)
        assert_equal 'great danes', search.query
      end
      
      should "be able to create a saved search" do
        stub_post("/1/saved_searches/create.json", "saved_search.json")
        search = @twitter.saved_search_create("great danes")
        assert_equal 'great danes', search.query
      end
      
      should "be able to delete a saved search" do
        stub_delete("/1/saved_searches/destroy/7095598.json", "saved_search.json")
        search = @twitter.saved_search_destroy(7095598)
        assert_equal 'great danes', search.query
      end
    end

    context "when using lists" do

      should "be able to create a new list" do
        stub_post("/1/pengwynn/lists.json", "list.json")
        list = @twitter.list_create("pengwynn", {:name => "Rubyists"})
        assert_equal 'Rubyists', list.name
        assert_equal 'rubyists', list.slug
        assert_equal 'public', list.mode
      end

      should "be able to update a list" do
        stub_put("/1/pengwynn/lists/rubyists.json", "list.json")
        list = @twitter.list_update("pengwynn", "rubyists", {:name => "Rubyists"})
        assert_equal 'Rubyists', list.name
        assert_equal 'rubyists', list.slug
        assert_equal 'public', list.mode
      end

      should "be able to delete a list" do
        stub_delete("/1/pengwynn/lists/rubyists.json", "list.json")
        list = @twitter.list_delete("pengwynn", "rubyists")
        assert_equal 'Rubyists', list.name
        assert_equal 'rubyists', list.slug
        assert_equal 'public', list.mode
      end

      should "be able to view lists to which a user belongs" do
        stub_get("/1/pengwynn/lists/memberships.json", "memberships.json")
        lists = @twitter.memberships("pengwynn").lists
        assert_equal 16, lists.size
        assert_equal 'web-dev', lists.first.name
        assert_equal 38, lists.first.member_count
      end

      should "be able to view lists for the authenticated user" do
        stub_get("/1/pengwynn/lists.json", "lists.json")
        lists = @twitter.lists("pengwynn").lists
        assert_equal 1, lists.size
        assert_equal 'Rubyists', lists.first.name
        assert_equal 'rubyists', lists.first.slug
      end
      
      should "be able to view the user owned lists without passing the screen_name" do
        stub_get("/1/lists.json", "lists.json")
        lists = @twitter.lists.lists
        assert_equal 1, lists.size
        assert_equal 'Rubyists', lists.first.name
        assert_equal 'rubyists', lists.first.slug
      end
      
      should "be able to view lists for the authenticated user by passing in a cursor" do
        stub_get("/1/pengwynn/lists.json?cursor=-1", "lists.json")
        lists = @twitter.lists("pengwynn", :cursor => -1).lists
        assert_equal 1, lists.size
        assert_equal 'Rubyists', lists.first.name
        assert_equal 'rubyists', lists.first.slug
      end
      
      should "be able to view the user owned lists without passing the screen_name and passing in a cursor" do
        stub_get("/1/lists.json?cursor=-1", "lists.json")
        lists = @twitter.lists(:cursor => -1).lists
        assert_equal 1, lists.size
        assert_equal 'Rubyists', lists.first.name
        assert_equal 'rubyists', lists.first.slug
      end

      should "be able to view list details" do
        stub_get("/1/pengwynn/lists/rubyists.json", "list.json")
        list = @twitter.list("pengwynn", "rubyists")
        assert_equal 'Rubyists', list.name
        assert_equal 0, list.subscriber_count
      end

      should "be able to view list timeline" do
        stub_get("/1/pengwynn/lists/rubyists/statuses.json", "list_statuses.json")
        tweets = @twitter.list_timeline("pengwynn", "rubyists")
        assert_equal 20, tweets.size
        assert_equal 5272535583, tweets.first.id
        assert_equal 'John Nunemaker', tweets.first.user.name
      end

      should "be able to limit number of tweets in list timeline" do
        stub_get("/1/pengwynn/lists/rubyists/statuses.json?per_page=1", "list_statuses_1_1.json")
        tweets = @twitter.list_timeline("pengwynn", "rubyists", :per_page => 1)
        assert_equal 1, tweets.size
        assert_equal 5272535583, tweets.first.id
        assert_equal 'John Nunemaker', tweets.first.user.name
      end

      should "be able to paginate through the timeline" do
        stub_get("/1/pengwynn/lists/rubyists/statuses.json?page=1&per_page=1", "list_statuses_1_1.json")
        stub_get("/1/pengwynn/lists/rubyists/statuses.json?page=2&per_page=1", "list_statuses_2_1.json")
        tweets = @twitter.list_timeline("pengwynn", "rubyists", { :page => 1, :per_page => 1 })
        assert_equal 1, tweets.size
        assert_equal 5272535583, tweets.first.id
        assert_equal 'John Nunemaker', tweets.first.user.name
        tweets = @twitter.list_timeline("pengwynn", "rubyists", { :page => 2, :per_page => 1 })
        assert_equal 1, tweets.size
        assert_equal 5264324712, tweets.first.id
        assert_equal 'John Nunemaker', tweets.first.user.name
      end

      should "be able to view list members" do
        stub_get("/1/pengwynn/rubyists/members.json", "list_users.json")
        members = @twitter.list_members("pengwynn", "rubyists").users
        assert_equal 2, members.size
        assert_equal 'John Nunemaker', members.first.name
        assert_equal 'jnunemaker', members.first.screen_name
      end

      should "be able to add a member to a list" do
        stub_post("/1/pengwynn/rubyists/members.json", "user.json")
        user = @twitter.list_add_member("pengwynn", "rubyists", 4243)
        assert_equal 'jnunemaker', user.screen_name
      end

      should "be able to remove a member from a list" do
        stub_delete("/1/pengwynn/rubyists/members.json?id=4243", "user.json")
        user = @twitter.list_remove_member("pengwynn", "rubyists", 4243)
        assert_equal 'jnunemaker', user.screen_name
      end

      should "be able to check if a user is member of a list" do
        stub_get("/1/pengwynn/rubyists/members/4243.json", "user.json")
        assert @twitter.is_list_member?("pengwynn", "rubyists", 4243)
      end

      should "be able to view list subscribers" do
        stub_get("/1/pengwynn/rubyists/subscribers.json", "list_users.json")
        subscribers = @twitter.list_subscribers("pengwynn", "rubyists").users
        assert_equal 2, subscribers.size
        assert_equal 'John Nunemaker', subscribers.first.name
        assert_equal 'jnunemaker', subscribers.first.screen_name
      end

      should "be able to subscribe to a list" do
        stub_post("/1/pengwynn/rubyists/subscribers.json", "user.json")
        user = @twitter.list_subscribe("pengwynn", "rubyists")
        assert_equal 'jnunemaker', user.screen_name
      end

      should "be able to unsubscribe from a list" do
        stub_delete("/1/pengwynn/rubyists/subscribers.json", "user.json")
        user = @twitter.list_unsubscribe("pengwynn", "rubyists")
        assert_equal 'jnunemaker', user.screen_name
      end

      should "be able to view a members list subscriptions" do
        stub_get("/1/pengwynn/lists/subscriptions.json", "list_subscriptions.json")
        subscriptions = @twitter.subscriptions("pengwynn").lists
        assert_equal 1, subscriptions.size
        assert_equal '@chriseppstein/sass-users', subscriptions.first.full_name
        assert_equal 'sass-users', subscriptions.first.slug
      end

    end
  end
end
