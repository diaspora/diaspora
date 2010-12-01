require 'test_helper'

class SearchTest < Test::Unit::TestCase
  context "searching" do
    setup do
      @search = Twitter::Search.new
    end

    should "be able to initialize with a search term" do
      assert Twitter::Search.new('httparty').query[:q].include? 'httparty'
    end

    should "default user agent to Ruby Twitter Gem" do
      search = Twitter::Search.new('foo')
      assert_equal 'Ruby Twitter Gem', search.user_agent
    end

    should "allow overriding default user agent" do
      search = Twitter::Search.new('foo', :user_agent => 'Foobar')
      assert_equal 'Foobar', search.user_agent
    end

    should "pass user agent along with headers when making request" do
      Twitter::Search.expects(:get).with('http://search.twitter.com/search.json', {:format => :json, :query => {:q => 'foo'}, :headers => {'User-Agent' => 'Foobar'}})
      Twitter::Search.new('foo', :user_agent => 'Foobar').fetch()
    end

    should "be able to specify from" do
      assert @search.from('jnunemaker').query[:q].include? 'from:jnunemaker'
    end

    should "be able to specify not from" do
      assert @search.from('jnunemaker',true).query[:q].include? '-from:jnunemaker'
    end

    should "be able to specify to" do
      assert @search.to('jnunemaker').query[:q].include? 'to:jnunemaker'
    end

    should "be able to specify not to" do
      assert @search.to('jnunemaker',true).query[:q].include? '-to:jnunemaker'
    end

    should "be able to specify not referencing" do
      assert @search.referencing('jnunemaker',true).query[:q].include? '-@jnunemaker'
    end

    should "alias references to referencing" do
      assert @search.references('jnunemaker').query[:q].include? '@jnunemaker'
    end

    should "alias ref to referencing" do
      assert @search.ref('jnunemaker').query[:q].include? '@jnunemaker'
    end

    should "be able to specify containing" do
      assert @search.containing('milk').query[:q].include? 'milk'
    end

    should "be able to specify not containing" do
      assert @search.containing('milk', true).query[:q].include? '-milk'
    end

    should "alias contains to containing" do
      assert @search.contains('milk').query[:q].include? 'milk'
    end

    should "be able to specify retweeted" do
      assert @search.retweeted.query[:q].include? 'rt'
    end

    should "be able to specify not_retweeted" do
      assert @search.not_retweeted.query[:q].include? '-rt'
    end

    should "be able to specify filters" do
      assert @search.filter('links').query[:q].include? 'filter:links'
    end

    should "be able to specify hashed" do
      assert @search.hashed('twitter').query[:q].include? '#twitter'
    end

    should "be able to specify not hashed" do
      assert @search.hashed('twitter',true).query[:q].include? '-#twitter'
    end

    should "be able to specify the language" do
      @search.lang('en')
      @search.class.expects(:get).with('http://search.twitter.com/search.json', :query => {:lang => 'en', :q => ''}, :format => :json, :headers => {'User-Agent' => 'Ruby Twitter Gem'}).returns({'foo' => 'bar'})
      @search.fetch()
    end

    should "be able to specify the locale" do
      stub_get("http://search.twitter.com/search.json?q=&locale=ja", "search.json")
      @search.locale('ja')
      @search.fetch()
    end

    should "be able to specify the number of results per page" do
      @search.per_page(25)
      @search.class.expects(:get).with('http://search.twitter.com/search.json', :query => {:rpp => 25, :q => ''}, :format => :json, :headers => {'User-Agent' => 'Ruby Twitter Gem'}).returns({'foo' => 'bar'})
      @search.fetch()
    end

    should "be able to specify the page number" do
      @search.page(20)
      @search.class.expects(:get).with('http://search.twitter.com/search.json', :query => {:page => 20, :q => ''}, :format => :json, :headers => {'User-Agent' => 'Ruby Twitter Gem'}).returns({'foo' => 'bar'})
      @search.fetch()
    end

    should "be able to specify only returning results greater than an id" do
      @search.since(1234)
      @search.class.expects(:get).with('http://search.twitter.com/search.json', :query => {:since_id => 1234, :q => ''}, :format => :json, :headers => {'User-Agent' => 'Ruby Twitter Gem'}).returns({'foo' => 'bar'})
      @search.fetch()
    end

    should "be able to specify since a date" do
      @search.since_date('2009-04-14')
      @search.class.expects(:get).with('http://search.twitter.com/search.json', :query => { :since => '2009-04-14', :q => ''}, :format => :json, :headers => {'User-Agent' => 'Ruby Twitter Gem'}).returns({ 'foo' => 'bar'})
      @search.fetch
    end

    should "be able to specify until a date" do
      @search.until_date('2009-04-14')
      @search.class.expects(:get).with('http://search.twitter.com/search.json', :query => { :until => '2009-04-14', :q => ''}, :format => :json, :headers => {'User-Agent' => 'Ruby Twitter Gem'}).returns({ 'foo' => 'bar'})
      @search.fetch
    end

    should "be able to specify geo coordinates" do
      @search.geocode('40.757929', '-73.985506', '25mi')
      @search.class.expects(:get).with('http://search.twitter.com/search.json', :query => {:geocode => '40.757929,-73.985506,25mi', :q => ''}, :format => :json, :headers => {'User-Agent' => 'Ruby Twitter Gem'}).returns({'foo' => 'bar'})
      @search.fetch()
    end

    should "be able to specify max id" do
      @search.max(1234)
      @search.class.expects(:get).with('http://search.twitter.com/search.json', :query => {:max_id => 1234, :q => ''}, :format => :json, :headers => {'User-Agent' => 'Ruby Twitter Gem'}).returns({'foo' => 'bar'})
      @search.fetch()
    end

    should "be able to set the phrase" do
      @search.phrase("Who Dat")
      @search.class.expects(:get).with('http://search.twitter.com/search.json', :query => {:phrase => "Who Dat", :q => ''}, :format => :json, :headers => {'User-Agent' => 'Ruby Twitter Gem'}).returns({'foo' => 'bar'})
      @search.fetch()
    end

    should "be able to set the result type" do
      @search.result_type("popular")
      @search.class.expects(:get).with('http://search.twitter.com/search.json', :query => {:result_type => 'popular', :q => ''}, :format => :json, :headers => {'User-Agent' => 'Ruby Twitter Gem'}).returns({'foo' => 'bar'})
      @search.fetch()
    end

    should "be able to clear the filters set" do
      @search.from('jnunemaker').to('oaknd1')
      assert_equal [], @search.clear.query[:q]
    end

    should "be able to chain methods together" do
      @search.from('jnunemaker').to('oaknd1').referencing('orderedlist').containing('milk').retweeted.hashed('twitter').lang('en').per_page(20).since(1234).geocode('40.757929', '-73.985506', '25mi')
      assert_equal ['from:jnunemaker', 'to:oaknd1', '@orderedlist', 'milk', 'rt', '#twitter'], @search.query[:q]
      assert_equal 'en', @search.query[:lang]
      assert_equal 20, @search.query[:rpp]
      assert_equal 1234, @search.query[:since_id]
      assert_equal '40.757929,-73.985506,25mi', @search.query[:geocode]
    end

    should "not replace the current query when fetching" do
      stub_get('http://search.twitter.com/search.json?q=milk%20cheeze', 'search_milk_cheeze.json')
      @search.containing('milk').containing('cheeze')
      assert_equal ['milk', 'cheeze'], @search.query[:q]
      @search.fetch
      assert_equal ['milk', 'cheeze'], @search.query[:q]
    end

    context "fetching" do
      setup do
        stub_get('http://search.twitter.com/search.json?q=%40jnunemaker', 'search.json')
        @search = Twitter::Search.new('@jnunemaker')
        @response = @search.fetch
      end

      should "return results" do
        assert_equal 15, @response.results.size
      end

      should "support dot notation" do
        first = @response.results.first
        assert_equal %q(Someone asked about a tweet reader. Easy to do in ruby with @jnunemaker's twitter gem and the win32-sapi gem, if you are on windows.), first.text
        assert_equal 'PatParslow', first.from_user
      end

      should "cache fetched results so multiple fetches don't keep hitting API" do
        Twitter::Search.expects(:get).never
        @search.fetch
      end

      should "rehit API if fetch is called with true" do
        Twitter::Search.expects(:get).once
        @search.fetch(true)
      end

      should "tell if another page is available" do
        assert @search.next_page?
      end

      should "be able to fetch the next page" do
        Twitter::Search.expects(:get).with('http://search.twitter.com/search.json', :query => 'page=2&max_id=1446791544&q=%40jnunemaker', :format => :json, :headers => {'User-Agent' => 'Ruby Twitter Gem'}).returns({'foo' => 'bar'})
        @search.fetch_next_page
      end
    end

    context "iterating over results" do
      setup do
        stub_get('http://search.twitter.com/search.json?q=from%3Ajnunemaker', 'search_from_jnunemaker.json')
        @search.from('jnunemaker')
      end

      should "work" do
        @search.each { |result| assert result }
      end

      should "work multiple times in a row" do
        @search.each { |result| assert result }
        @search.each { |result| assert result }
      end
    end

    should "be able to iterate over results" do
      assert_respond_to @search, :each
    end
  end

end
