require 'test_helper'

class RequestTest < Test::Unit::TestCase
  context "new get request" do
    setup do
      @client = mock('twitter client')
      @request = Twitter::Request.new(@client, :get, '/1/statuses/user_timeline.json', {:query => {:since_id => 1234}})
    end

    should "have client" do
      assert_equal @client, @request.client
    end

    should "have method" do
      assert_equal :get, @request.method
    end

    should "have path" do
      assert_equal '/1/statuses/user_timeline.json', @request.path
    end

    should "have options" do
      assert_equal 1234, @request.options[:query][:since_id]
    end

    should "have uri" do
      assert_equal '/1/statuses/user_timeline.json?since_id=1234', @request.uri
    end

    context "performing request for collection" do
      setup do
        response = mock('response') do
          stubs(:body).returns(fixture_file('user_timeline.json'))
          stubs(:code).returns('200')
        end

        @client.expects(:get).returns(response)
        @object = @request.perform
      end

      should "return array of mashes" do
        assert_equal 20, @object.size
        assert_equal Hashie::Mash, @object.first.class
        assert_equal 'Colder out today than expected. Headed to the Beanery for some morning wakeup drink. Latte or coffee...hmmm...', @object.first.text
      end
    end

    context "performing a request for a single object" do
      setup do
        response = mock('response') do
          stubs(:body).returns(fixture_file('status.json'))
          stubs(:code).returns('200')
        end

        @client.expects(:get).returns(response)
        @object = @request.perform
      end

      should "return a single mash" do
        assert_kind_of Hashie::Mash, @object
        assert_equal 'Rob Dyrdek is the funniest man alive. That is all.', @object.text
      end
    end

    context "with no query string" do
      should "not have any query string" do
        request = Twitter::Request.new(@client, :get, '/1/statuses/user_timeline.json')
        assert_equal '/1/statuses/user_timeline.json', request.uri
      end
    end

    context "with blank query string" do
      should "not have any query string" do
        request = Twitter::Request.new(@client, :get, '/1/statuses/user_timeline.json', :query => {})
        assert_equal '/1/statuses/user_timeline.json', request.uri
      end
    end

    should "have get shortcut to initialize and perform all in one" do
      Twitter::Request.any_instance.expects(:perform).returns(nil)
      Twitter::Request.get(@client, '/foo')
    end

    should "allow setting query string and headers" do
      response = mock('response') do
        stubs(:body).returns('')
        stubs(:code).returns('200')
      end

      @client.expects(:get).with('/1/statuses/friends_timeline.json?since_id=1234', {'Foo' => 'Bar'}).returns(response)
      Twitter::Request.get(@client, '/1/statuses/friends_timeline.json?since_id=1234', :headers => {'Foo' => 'Bar'})
    end
  end

  context "new post request" do
    setup do
      @client = mock('twitter client')
      @request = Twitter::Request.new(@client, :post, '/1/statuses/update.json', {:body => {:status => 'Woohoo!'}})
    end

    should "allow setting body and headers" do
      response = mock('response') do
        stubs(:body).returns('')
        stubs(:code).returns('200')
      end

      @client.expects(:post).with('/1/statuses/update.json', {:status => 'Woohoo!'}, {'Foo' => 'Bar'}).returns(response)
      Twitter::Request.post(@client, '/1/statuses/update.json', :body => {:status => 'Woohoo!'}, :headers => {'Foo' => 'Bar'})
    end

    context "performing request" do
      setup do
        response = mock('response') do
          stubs(:body).returns(fixture_file('status.json'))
          stubs(:code).returns('200')
        end

        @client.expects(:post).returns(response)
        @object = @request.perform
      end

      should "return a mash of the object" do
        assert_equal 'Rob Dyrdek is the funniest man alive. That is all.', @object.text
      end
    end

    should "have post shortcut to initialize and perform all in one" do
      Twitter::Request.any_instance.expects(:perform).returns(nil)
      Twitter::Request.post(@client, '/foo')
    end
  end

  context "error raising" do
    setup do
      oauth = Twitter::OAuth.new('token', 'secret')
      oauth.authorize_from_access('atoken', 'asecret')
      @client = Twitter::Base.new(oauth)
    end

    should "not raise error for 200" do
      stub_get('http://api.twitter.com/foo', '', ['200'])
      assert_nothing_raised do
        Twitter::Request.get(@client, '/foo')
      end
    end

    should "not raise error for 304" do
      stub_get('http://api.twitter.com/foo', '', ['304'])
      assert_nothing_raised do
        Twitter::Request.get(@client, '/foo')
      end
    end

    should "raise RateLimitExceeded for 400" do
      stub_get('http://api.twitter.com/foo', 'rate_limit_exceeded.json', ['400'])
      assert_raise Twitter::RateLimitExceeded do
        Twitter::Request.get(@client, '/foo')
      end
    end

    should "raise Unauthorized for 401" do
      stub_get('http://api.twitter.com/foo', '', ['401'])
      assert_raise Twitter::Unauthorized do
        Twitter::Request.get(@client, '/foo')
      end
    end

    should "raise General for 403" do
      stub_get('http://api.twitter.com/foo', '', ['403'])
      assert_raise Twitter::General do
        Twitter::Request.get(@client, '/foo')
      end
    end

    should "raise NotFound for 404" do
      stub_get('http://api.twitter.com/foo', '', ['404'])
      assert_raise Twitter::NotFound do
        Twitter::Request.get(@client, '/foo')
      end
    end

    should "raise InformTwitter for 500" do
      stub_get('http://api.twitter.com/foo', '', ['500'])
      assert_raise Twitter::InformTwitter do
        Twitter::Request.get(@client, '/foo')
      end
    end

    should "raise Unavailable for 502" do
      stub_get('http://api.twitter.com/foo', '', ['502'])
      assert_raise Twitter::Unavailable do
        Twitter::Request.get(@client, '/foo')
      end
    end

    should "raise Unavailable for 503" do
      stub_get('http://api.twitter.com/foo', '', ['503'])
      assert_raise Twitter::Unavailable do
        Twitter::Request.get(@client, '/foo')
      end
    end
  end

  context "Making request with mash option set to false" do
    setup do
      oauth = Twitter::OAuth.new('token', 'secret')
      oauth.authorize_from_access('atoken', 'asecret')
      @client = Twitter::Base.new(oauth)
    end

    should "not attempt to create mash of return object" do
      stub_get('http://api.twitter.com/foo', 'friend_ids.json')
      object = Twitter::Request.get(@client, '/foo', :mash => false)
      assert_kind_of Array, object
      assert_kind_of Fixnum, object.first
    end
  end
end
