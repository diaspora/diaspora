The Twitter Ruby Gem
====================
A Ruby wrapper for the Twitter REST and Search APIs

Installation
------------
    gem install twitter

Documentation
-------------
[http://rdoc.info/gems/twitter](http://rdoc.info/gems/twitter)

Follow @gem on Twitter
----------------------
You should [follow @gem on Twitter](http://twitter.com/#!/gem) for announcements,
updates, and news about the twitter gem.

Join the mailing list!
----------------------
[https://groups.google.com/group/ruby-twitter-gem](https://groups.google.com/group/ruby-twitter-gem)

Does your project or organization use this gem?
-----------------------------------------------
Add it to the [apps](https://github.com/jnunemaker/twitter/wiki/apps) wiki!

Continuous Integration
----------------------
[![Build Status](http://travis-ci.org/jnunemaker/twitter.png)](http://travis-ci.org/jnunemaker/twitter)

What's new in 1.1?
------------------
This version no longer requires that you explicitly pass the authenticated
user's ID or screen name.

**Pre-1.1**

    Twitter.configure do |config|
      config.consumer_key = YOUR_CONSUMER_KEY
      config.consumer_secret = YOUR_CONSUMER_SECRET
      config.oauth_token = YOUR_OAUTH_TOKEN
      config.oauth_token_secret = YOUR_OAUTH_TOKEN_SECRET
    end

    Twitter.user("sferik")
**Post-1.1**

    Twitter.configure do |config|
      config.consumer_key = YOUR_CONSUMER_KEY
      config.consumer_secret = YOUR_CONSUMER_SECRET
      config.oauth_token = YOUR_OAUTH_TOKEN
      config.oauth_token_secret = YOUR_OAUTH_TOKEN_SECRET
    end

    Twitter.user

What's new in 1.0?
------------------
This gem has been completely rewritten for version 1.0 thanks to [contributions from numerous
people](https://github.com/jnunemaker/twitter/blob/master/HISTORY.md). This rewrite breaks
compatibility with version 0.9.12 and earlier versions of the gem. Most notably, the
<tt>Twitter::Base</tt>, <tt>Twitter:Geo</tt>, <tt>Twitter::LocalTrends</tt>, and
<tt>Twitter::Trends</tt> classes [have all been merged](https://github.com/jnunemaker/twitter/commit/eb53872249634ee1f0179982b091a1a0fd9c0973) into
the <tt>Twitter::Client</tt> class. Whenever possible, we [display deprecation warnings and forward method
calls to the <tt>Twitter::Client</tt> class](https://github.com/jnunemaker/twitter/commit/192e5884f367750dbdca8471aa12385ed5b057ca).
In a handful of cases, method names were changed to resolve namespace conflicts.

**Pre-1.0**

    Twitter::Base.new.user("sferik").name
**Post-1.0**

    Twitter::Client.new.user("sferik").name

The <tt>Twitter::Search</tt> class has remained largely the same, however it no longer accepts a
query in its constructor. You can specify a query using the <tt>#containing</tt> method, which is
aliased to <tt>#q</tt>.

**Pre-1.0**

    Twitter::Search.new("query").fetch.first.text
**Post-1.0**

    Twitter::Search.new.q("query").fetch.first.text

The error classes have gone through a transformation to make them consistent with [Twitter's documented
response codes](http://dev.twitter.com/pages/responses_errors). These changes should make it easier to
rescue from specific errors and take action accordingly. We've also added support for two new classes of
error returned by the Twitter Search API.

<table>
  <thead>
    <tr>
      <th>Response Code</th>
      <th>Pre-1.0</th>
      <th>Post-1.0</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><tt>400</tt></td>
      <td><tt>Twitter::RateLimitExceeded</tt></td>
      <td><tt>Twitter::BadRequest</tt></td>
    </tr>
    <tr>
      <td><tt>401</tt></td>
      <td><tt>Twitter::Unauthorized</tt></td>
      <td><tt>Twitter::Unauthorized</tt></td>
    </tr>
    <tr>
      <td><tt>403</tt></td>
      <td><tt>Twitter::General</tt></td>
      <td><tt>Twitter::Forbidden</tt></td>
    </tr>
    <tr>
      <td><tt>404</tt></td>
      <td><tt>Twitter::NotFound</tt></td>
      <td><tt>Twitter::NotFound</tt></td>
    </tr>
    <tr>
      <td><tt>406</tt></td>
      <td>N/A</td>
      <td><tt>Twitter::NotAcceptable</tt></td>
    </tr>
    <tr>
      <td><tt>420</tt></td>
      <td>N/A</td>
      <td><tt>Twitter::EnhanceYourCalm</tt></td>
    </tr>
    <tr>
      <td><tt>500</tt></td>
      <td><tt>Twitter::InformTwitter</tt></td>
      <td><tt>Twitter::InternalServerError</tt></td>
    </tr>
    <tr>
      <td><tt>502</tt></td>
      <td><tt>Twitter::Unavailable</tt></td>
      <td><tt>Twitter::BadGateway</tt></td>
    </tr>
    <tr>
      <td><tt>503</tt></td>
      <td><tt>Twitter::Unavailable</tt></td>
      <td><tt>Twitter::ServiceUnavailable</tt></td>
    </tr>
  </tbody>
</table>

Additionally, the <tt>Twitter::OAuth</tt> class [has been removed](https://github.com/jnunemaker/twitter/commit/d33b119cdfdaefb10db99e56d28dd69625816edf).
This class was just a wrapper to get access tokens via the [oauth
gem](https://github.com/oauth/oauth-ruby). Given that there are a variety of gems that do the same
thing ([twitter-auth](https://github.com/mbleigh/twitter-auth),
[omniauth](https://github.com/intridea/omniauth), and
[devise](https://github.com/plataformatec/devise), to name a few) we decided to decouple
this functionality so you can use whichever authentication library you prefer, or none at all. If
you would like to see how to use the [omniauth
gem](https://github.com/intridea/omniauth) for authentication, Erik
Michaels-Ober maintains [a simple Rails
application](https://github.com/sferik/sign-in-with-twitter) that demonstrates
how to do so.

The public APIs defined in version 1.0 of this gem will maintain backwards compatibility until
the next major version, following the best practice of [Semantic Versioning](http://semver.org/).
You are free to continue using the 0.9 series of the gem; however, it will not be maintained so
upgrading to 1.0 is strongly recommended.

Here are a few more reasons to upgrade to 1.0:

* Full Ruby 1.9 compatibility: All code and specs now work in the latest version of Ruby
* Support for HTTP proxies: Access Twitter from China, Iran, or inside your office firewall
* Support for multiple HTTP adapters: NetHttp (default), Typhoeus, Patron, or ActionDispatch
* Support for multiple Twitter response formats: JSON (default) or XML
* More flexible: Parse JSON or XML with the engine of your choosing via [MultiJSON](https://github.com/intridea/multi_json) and [MultiXML](https://github.com/sferik/multi_xml)
* More RESTful: Uses HTTP DELETE (instead of POST) when requesting destructive resources
* More methods: Request any documented resource in the Twitter API, including all [#newtwitter resources](http://groups.google.com/group/twitter-development-talk/browse_thread/thread/cdc34ae78a2350b8)
* SSL: On by default for increased [speed](https://gist.github.com/652330) and security
* Improved error handling: More easily rescue from rate-limit errors or fail whales

Performance
-----------
You can improve performance by preloading a faster JSON or XML parsing library.
By default, the JSON will be parsed with [okjson][okjson] and XML will be
parsed with [REXML][rexml]. For faster JSON parsing, we recommend
[yajl-ruby][yajl] and for faster XML parsing, we recommend
[libxml-ruby][libxml] or [nokogiri][nokogiri].

[okjson]: https://github.com/ddollar/okjson
[rexml]: http://www.germane-software.com/software/rexml
[yajl]: https://github.com/brianmario/yajl-ruby
[libxml]: https://github.com/dvdplm/libxml-ruby
[nokogiri]: http://nokogiri.org

Usage Examples
--------------
    require "rubygems"
    require "twitter"

    # Get a user's location
    puts Twitter.user("sferik").location

    # Get a user's most recent status update
    puts Twitter.user_timeline("sferik").first.text

    # Get a status update by id
    puts Twitter.status(27558893223).text

    # Initialize a Twitter search client
    search = Twitter::Search.new

    # Find the 3 most recent marriage proposals to @justinbieber
    search.containing("marry me").to("justinbieber").result_type("recent").per_page(3).each do |r|
      puts "#{r.from_user}: #{r.text}"
    end

    # Enough about Justin Bieber
    search.clear

    # Let's find a Japanese-language tweet tagged #ruby
    puts search.hashtag("ruby").language("ja").no_retweets.per_page(1).fetch.first.text

    # And another
    puts search.fetch_next_page.first.text

    # Certain methods require authentication. To get your Twitter OAuth credentials,
    # register an app at http://dev.twitter.com/apps
    Twitter.configure do |config|
      config.consumer_key = YOUR_CONSUMER_KEY
      config.consumer_secret = YOUR_CONSUMER_SECRET
      config.oauth_token = YOUR_OAUTH_TOKEN
      config.oauth_token_secret = YOUR_OAUTH_TOKEN_SECRET
    end

    # Update your status
    Twitter.update("I'm tweeting from the Twitter Ruby Gem!")

    # Read the most recent tweet in your home timeline
    puts Twitter.home_timeline.first.text

    # Who's your most popular friend?
    puts Twitter.friends.users.sort{|a, b| a.followers_count <=> b.followers_count}.reverse.first.name

    # Who's your most popular follower?
    puts Twitter.followers.users.sort{|a, b| a.followers_count <=> b.followers_count}.reverse.first.name

    # Get your rate limit status
    puts Twitter.rate_limit_status.remaining_hits.to_s + " Twitter API request(s) remaining this hour"

Contributing
------------
In the spirit of [free software](http://www.fsf.org/licensing/essays/free-sw.html), **everyone** is encouraged to help improve this project.

Here are some ways *you* can contribute:

* by using alpha, beta, and prerelease versions
* by reporting bugs
* by suggesting new features
* by writing or editing documentation
* by writing specifications
* by writing code (**no patch is too small**: fix typos, add comments, clean up inconsistent whitespace)
* by refactoring code
* by closing [issues](https://github.com/jnunemaker/twitter/issues)
* by reviewing patches
* [financially](http://pledgie.com/campaigns/1193)

All contributors will be added to the [HISTORY](https://github.com/jnunemaker/twitter/blob/master/HISTORY.md)
file and will receive the respect and gratitude of the community.

Submitting an Issue
-------------------
We use the [GitHub issue tracker](https://github.com/jnunemaker/twitter/issues) to track bugs and
features. Before submitting a bug report or feature request, check to make sure it hasn't already
been submitted. You can indicate support for an existing issuse by voting it up. When submitting a
bug report, please include a [Gist](https://gist.github.com/) that includes a stack trace and any
details that may be necessary to reproduce the bug, including your gem version, Ruby version, and
operating system. Ideally, a bug report should include a pull request with failing specs.

Submitting a Pull Request
-------------------------
1. Fork the project.
2. Create a topic branch.
3. Implement your feature or bug fix.
4. Add documentation for your feature or bug fix.
5. Run <tt>bundle exec rake doc:yard</tt>. If your changes are not 100% documented, go back to step 4.
6. Add specs for your feature or bug fix.
7. Run <tt>bundle exec rake spec</tt>. If your changes are not 100% covered, go back to step 6.
8. Commit and push your changes.
9. Submit a pull request. Please do not include changes to the gemspec, version, or history file. (If you want to create your own version for some reason, please do so in a separate commit.)

Copyright
---------
Copyright (c) 2010 John Nunemaker, Wynn Netherland, Erik Michaels-Ober, Steve Richert.
See [LICENSE](https://github.com/jnunemaker/twitter/blob/master/LICENSE.md) for details.
