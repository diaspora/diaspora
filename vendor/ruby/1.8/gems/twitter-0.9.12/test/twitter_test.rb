require 'test_helper'

class TwitterTest < Test::Unit::TestCase

  should "default User Agent to 'Ruby Twitter Gem'" do
    assert_equal 'Ruby Twitter Gem', Twitter.user_agent
  end

  context 'when overriding the user agent' do
    should "be able to specify the User Agent" do
      Twitter.user_agent = 'My Twitter Gem'
      assert_equal 'My Twitter Gem', Twitter.user_agent
    end
  end

  should "have firehose method for public timeline" do
    stub_get('http://api.twitter.com/1/statuses/public_timeline.json', 'firehose.json')
    hose = Twitter.firehose
    assert_equal 20, hose.size
    first = hose.first
    assert_equal '#torrents Ultimativer Flirt Guide - In 10 Minuten jede Frau erobern: Ultimativer Flirt Guide - In 10 Mi.. http://tinyurl.com/d3okh4', first.text
    assert_equal 'P2P Torrents', first.user.name
  end

  should "have user method for unauthenticated calls to get a user's information" do
    stub_get('http://api.twitter.com/1/users/show/jnunemaker.json', 'user.json')
    user = Twitter.user('jnunemaker')
    assert_equal 'John Nunemaker', user.name
    assert_equal 'Loves his wife, ruby, notre dame football and iu basketball', user.description
  end

  should "have status method for unauthenticated calls to get a status" do
    stub_get('http://api.twitter.com/1/statuses/show/1533815199.json', 'status_show.json')
    status = Twitter.status(1533815199)
    assert_equal 1533815199, status.id
    assert_equal 'Eating some oatmeal and butterscotch cookies with a cold glass of milk for breakfast. Tasty!', status.text
  end

  should "raise NotFound for unauthenticated calls to get a deleted or nonexistent status" do
    stub_get('http://api.twitter.com/1/statuses/show/1.json', 'not_found.json', 404)
    assert_raise Twitter::NotFound do
      Twitter.status(1)
    end
  end

  should "have a timeline method for unauthenticated calls to get a user's timeline" do
    stub_get('http://api.twitter.com/1/statuses/user_timeline/jnunemaker.json', 'user_timeline.json')
    statuses = Twitter.timeline('jnunemaker')
    assert_equal 1445986256, statuses.first.id
    assert_equal 'jnunemaker', statuses.first.user.screen_name
  end

  should "raise Unauthorized for unauthenticated calls to get a protected user's timeline" do
    stub_get('http://api.twitter.com/1/statuses/user_timeline/protected.json', 'unauthorized.json', 401)
    assert_raise Twitter::Unauthorized do
      Twitter.timeline('protected')
    end
  end

  should "have friend_ids method" do
    stub_get('http://api.twitter.com/1/friends/ids/jnunemaker.json', 'friend_ids.json')
    ids = Twitter.friend_ids('jnunemaker')
    assert_equal 161, ids.size
  end

  should "raise Unauthorized for unauthenticated calls to get a protected user's friend_ids" do
    stub_get('http://api.twitter.com/1/friends/ids/protected.json', 'unauthorized.json', 401)
    assert_raise Twitter::Unauthorized do
      Twitter.friend_ids('protected')
    end
  end

  should "have follower_ids method" do
    stub_get('http://api.twitter.com/1/followers/ids/jnunemaker.json', 'follower_ids.json')
    ids = Twitter.follower_ids('jnunemaker')
    assert_equal 1252, ids.size
  end

  should "raise Unauthorized for unauthenticated calls to get a protected user's follower_ids" do
    stub_get('http://api.twitter.com/1/followers/ids/protected.json', 'unauthorized.json', 401)
    assert_raise Twitter::Unauthorized do
      Twitter.follower_ids('protected')
    end
  end

  context "when using lists" do

    should "be able to view list timeline" do
      stub_get('http://api.twitter.com/1/pengwynn/lists/rubyists/statuses.json', 'list_statuses.json')
      tweets = Twitter.list_timeline('pengwynn', 'rubyists')
      assert_equal 20, tweets.size
      assert_equal 5272535583, tweets.first.id
      assert_equal 'John Nunemaker', tweets.first.user.name
    end

    should "be able to limit number of tweets in list timeline" do
      stub_get('http://api.twitter.com/1/pengwynn/lists/rubyists/statuses.json?per_page=1', 'list_statuses_1_1.json')
      tweets = Twitter.list_timeline('pengwynn', 'rubyists', :per_page => 1)
      assert_equal 1, tweets.size
      assert_equal 5272535583, tweets.first.id
      assert_equal 'John Nunemaker', tweets.first.user.name
    end

    should "be able to paginate through the timeline" do
      stub_get('http://api.twitter.com/1/pengwynn/lists/rubyists/statuses.json?page=1&per_page=1', 'list_statuses_1_1.json')
      stub_get('http://api.twitter.com/1/pengwynn/lists/rubyists/statuses.json?page=2&per_page=1', 'list_statuses_2_1.json')
      tweets = Twitter.list_timeline('pengwynn', 'rubyists', { :page => 1, :per_page => 1 })
      assert_equal 1, tweets.size
      assert_equal 5272535583, tweets.first.id
      assert_equal 'John Nunemaker', tweets.first.user.name
      tweets = Twitter.list_timeline('pengwynn', 'rubyists', { :page => 2, :per_page => 1 })
      assert_equal 1, tweets.size
      assert_equal 5264324712, tweets.first.id
      assert_equal 'John Nunemaker', tweets.first.user.name
    end

  end
end
